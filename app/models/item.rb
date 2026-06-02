class Item < ApplicationRecord
  belongs_to :establishment

  has_many :order_lines
end
