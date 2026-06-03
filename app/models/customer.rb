class Customer < ApplicationRecord
  belongs_to :establishment

  has_many :orders

  # Clients nommés uniquement (exclut les clients anonymes des listes / comptages).
  scope :named, -> { where(is_anonymous: false) }

  # Un client nommé doit avoir une identité ; un client anonyme n'en a pas besoin.
  validates :firstname, presence: true, unless: :is_anonymous?
  validates :lastname,  presence: true, unless: :is_anonymous?

  # Référence lisible ANON-00042, générée pour les seuls clients anonymes.
  after_create :generate_anon_ref, if: :is_anonymous?

  def display_name
    return anon_ref if is_anonymous?

    [firstname, lastname].compact.join(" ").strip.presence || email.presence || "Client ##{id}"
  end

  # Affichage compact "Prénom N." (ou la réf anonyme). Sûr même sans nom.
  def short_name
    return anon_ref if is_anonymous?

    "#{firstname} #{lastname&.first}.".strip
  end

  def initials
    return "AN" if is_anonymous?

    display_name
      .split
      .map { |word| word[0] }
      .join
      .first(2)
      .upcase
  end

  # Un client peut être facturé (facture nominative) s'il est nommé ET identifié.
  # Un anonyme ne donne droit qu'à un reçu.
  def invoiceable?
    !is_anonymous? && firstname.present? && lastname.present?
  end

  private

  def generate_anon_ref
    update_column(:anon_ref, format("ANON-%05d", id))
  end
end
