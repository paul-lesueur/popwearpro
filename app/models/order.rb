class Order < ApplicationRecord
  include OrderTotals

  ARCHIVE_THRESHOLD_DAYS = 14
  DONE_STATUSES = %w[completed delivered].freeze
  # Statut « commande prête / en attente de retrait » (colonne kanban "recollect").
  READY_STATUS = "sent".freeze
  # Paliers (en jours ouvrés) déclenchant un rappel SMS si la commande n'est
  # toujours pas retirée. Du plus grand au plus petit pour la résolution du palier.
  PICKUP_REMINDER_DAYS = [10, 3].freeze

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
  # Horodate l'entrée en « attente de retrait » (et la réinitialise à la sortie),
  # pour pouvoir compter les jours ouvrés écoulés avant un rappel.
  before_save :track_ready_at
  before_save :auto_mark_paid_on_completion

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

  # Nombre de jours ouvrés (lundi→vendredi) entre deux dates, bornes incluses au
  # départ, exclue à l'arrivée. Renvoie 0 si la commande vient juste d'être prête.
  def self.business_days_between(from_date, to_date)
    return 0 if from_date.blank? || to_date.blank? || to_date <= from_date

    (from_date...to_date).count { |day| (1..5).include?(day.wday) }
  end

  # Jours ouvrés écoulés depuis l'entrée en attente de retrait, ou nil si la
  # commande n'est pas (ou plus) dans cet état.
  def business_days_waiting
    return nil unless status == READY_STATUS && ready_at.present?

    Order.business_days_between(ready_at.to_date, Date.current)
  end

  # Palier de rappel à proposer (10, 3 ou nil) : le plus haut seuil atteint dont
  # le rappel n'a pas encore été envoyé. L'alerte disparaît donc palier par palier.
  def pickup_reminder_level
    waiting = business_days_waiting
    return nil if waiting.nil?

    PICKUP_REMINDER_DAYS.find { |days| waiting >= days && !reminder_sent?(days) }
  end

  # Un rappel de ce palier a-t-il déjà été (ou est-il en cours d') envoyé ?
  def reminder_sent?(level)
    communications.where(channel: "sms", kind: "reminder_j#{level}")
                  .where.not(status: "failed").exists?
  end

  # Crée la communication SMS de rappel « commande non retirée » et l'envoie.
  def send_pickup_reminder!(level)
    return if customer&.phone.blank?

    communication = communications.create!(
      kind: "reminder_j#{level}",
      channel: "sms",
      status: "pending",
      content: pickup_reminder_message
    )
    SendSmsJob.perform_later(communication.id)
    communication
  end

  def pickup_reminder_message
    name = customer&.firstname.presence || "client"
    shop = establishment&.name.presence || "votre atelier"
    "Bonjour #{name}, petit rappel : votre commande CMD-#{id} vous attend " \
      "toujours chez #{shop}. Pensez à venir la retirer !"
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

  def auto_mark_paid_on_completion
    return unless status_changed? && DONE_STATUSES.include?(status)
    return unless status_was == READY_STATUS
    return if payment_status == "paid"

    self.payment_status = "paid"
  end

  def set_default_discount
    self.discount = 0 if discount.blank?
  end

  def set_completed_at
    return unless status_changed? && DONE_STATUSES.include?(status)

    self.completed_at ||= Time.current
  end

  def track_ready_at
    return unless status_changed?

    if status == READY_STATUS
      self.ready_at ||= Time.current
    else
      # La commande quitte l'attente de retrait : on repart à zéro pour un
      # éventuel passage ultérieur.
      self.ready_at = nil
    end
  end
end
