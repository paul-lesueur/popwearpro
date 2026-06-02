class Customer < ApplicationRecord
  belongs_to :establishment

  has_many :orders
end
