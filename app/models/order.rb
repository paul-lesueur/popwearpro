class Order < ApplicationRecord
  belongs_to :establishment
  belongs_to :customer

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

  def urgent?
    due_date.present? && due_date <= Date.current + 2.days && status != "delivered"
  end

  def paid?
    payment_status == "paid"
  end
end
