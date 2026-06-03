class Establishment < ApplicationRecord
  belongs_to :user

  has_many :customers, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :orders, dependent: :destroy

  has_one_attached :photo

  PAYMENT_METHODS = [
    {
      value: "Carte bancaire",
      label: "Cartes bancaires",
      icon: "fa-credit-card"
    },
    {
      value: "Espèces",
      label: "Espèces",
      icon: "fa-eur"
    },
    {
      value: "Chèques",
      label: "Chèques",
      icon: "fa-check"
    }
  ].freeze

  def payment_methods_array
    payment_methods.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
