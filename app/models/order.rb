class Order < ApplicationRecord
  include OrderTotals

  ARCHIVE_THRESHOLD_DAYS = 14
  DONE_STATUSES = %w[completed delivered].freeze
  # Statut « commande prête / en attente de retrait » (colonne kanban "recollect").
  READY_STATUS = "sent".freeze

  belongs_to :establishment
  belongs_to :customer

  has_many :order_lines, dependent: :destroy
  has_many :communications, dependent: :destroy

  accepts_nested_attributes_for :order_lines,
                                reject_if: proc { |attributes| attributes["item_id"].blank? },
                                allow_destroy: true

  scope :archived,     -> { where.not(archived_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }

  before_validation :set_default_discount
  before_save :set_completed_at

  # Email de confirmation transactionnel, uniquement si le client a un email.
  after_create_commit :send_confirmation_email
  # Rappel « commande prête » : envoyé quand la commande passe en attente de
  # retrait, si le rappel SMS a été activé sur la commande.
  after_update_commit :notify_ready_by_sms_if_enabled

  # Crée la communication SMS « commande prête » et déclenche son envoi.
  # Réutilisé par l'envoi automatique (toggle) et l'envoi manuel.
  def notify_ready_by_sms!
    return if customer&.phone.blank?

    communication = communications.create!(
      kind: "ready",
      channel: "sms",
      status: "pending",
      content: sms_ready_message
    )
    SendSmsJob.perform_later(communication.id)
    communication
  end

  def sms_ready_message
    name = customer&.firstname.presence || "client"
    shop = establishment&.name.presence || "votre atelier"
    "Bonjour #{name}, votre commande CMD-#{id} est prête à être retirée chez #{shop}."
  end

  def self.auto_archive_done!(establishment)
    threshold = ARCHIVE_THRESHOLD_DAYS.days.ago

    establishment.orders
                 .where(status: DONE_STATUSES, archived_at: nil)
                 .where(
                   "COALESCE(due_date, completed_at, updated_at) < ?",
                   threshold
                 )
                 .update_all(archived_at: Time.current)
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  # Total réellement dû après réduction (jamais négatif).
  def total_due
    [total_ttc - discount.to_f, 0].max
  end

  def urgent?
    due_date.present? && due_date <= Date.current + 2.days && !DONE_STATUSES.include?(status)
  end

  def paid?
    payment_status == "paid"
  end

  # Conformité FR : un client anonyme ne donne droit qu'à un reçu/ticket,
  # un client nommé (identifié) donne lieu à une facture nominative.
  def document_type
    customer&.is_anonymous? ? :receipt : :invoice
  end

  def receipt?
    document_type == :receipt
  end

  def invoice?
    document_type == :invoice
  end

  def document_label
    receipt? ? "Reçu" : "Facture"
  end

  private

  def send_confirmation_email
    return unless email_confirmation?
    return if customer.email.blank?

    OrderMailer.confirmation(self).deliver_later
  end

  # Déclenche le SMS « prête » au passage en attente de retrait, si le rappel
  # est activé et qu'aucun SMS « prête » n'a déjà été (ou est en cours d') envoyé.
  def notify_ready_by_sms_if_enabled
    return unless sms_reminder?
    return unless saved_change_to_status? && status == READY_STATUS
    return if communications.where(channel: "sms", kind: "ready")
                            .where.not(status: "failed").exists?

    notify_ready_by_sms!
  end

  def set_default_discount
    self.discount = 0 if discount.blank?
  end

  def set_completed_at
    return unless status_changed? && DONE_STATUSES.include?(status)

    self.completed_at ||= Time.current
  end
end
