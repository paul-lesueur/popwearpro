class OrderLine < ApplicationRecord
  belongs_to :order
  belongs_to :item

  def total_ht
    quantity.to_i * unit_price_ht.to_f
  end

  def total_ttc
    total_ht * (1 + vat_rate.to_f / 100)
  end
end
