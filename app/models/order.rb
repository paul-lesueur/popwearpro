class Order < ApplicationRecord
  belongs_to :establishment
  belongs_to :customer

  has_many :order_lines
  has_many :communications
end
