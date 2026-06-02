class Establishment < ApplicationRecord
  belongs_to :user

  has_many :customers
  has_many :orders
  has_many :items
end
