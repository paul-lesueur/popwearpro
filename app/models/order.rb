class Order < ApplicationRecord
  ARCHIVE_THRESHOLD_DAYS = 14
  DONE_STATUSES = %w[completed delivered].freeze

  belongs_to :establishment
  belongs_to :customer

  scope :archived,     -> { where.not(archived_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }

  before_save :set_completed_at

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

  has_many :order_lines, dependent: :destroy
  has_many :communications, dependent: :destroy

  accepts_nested_attributes_for :order_lines,
                                reject_if: proc { |attributes| attributes["item_id"].blank? },
                                allow_destroy: true

  def total_ht
    order_lines.sum(&:total_ht)
  end

  def total_ttc
    order_lines.sum(&:total_ttc)
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

  def set_completed_at
    return unless status_changed? && DONE_STATUSES.include?(status)
    self.completed_at ||= Time.current
  end
end
