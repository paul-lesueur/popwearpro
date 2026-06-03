class Customer < ApplicationRecord
  belongs_to :establishment

  has_many :orders

  def display_name
    [firstname, lastname].compact.join(" ").strip.presence || email.presence || "Client ##{id}"
  end

  def initials
    display_name
      .split
      .map { |word| word[0] }
      .join
      .first(2)
      .upcase
  end
end
