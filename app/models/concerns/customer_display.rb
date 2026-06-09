# Libellés d'affichage compacts pour un client.
module CustomerDisplay
  extend ActiveSupport::Concern

  # Affichage compact "K. Benali" (initiale du prénom + nom).
  # Repli sur le prénom seul si le nom manque, la réf anonyme pour un client
  # anonyme, et "Client" si tout est vide.
  def short_name
    return anon_ref if is_anonymous?

    if firstname.present? && lastname.present?
      "#{firstname.first.upcase}. #{lastname}"
    elsif firstname.present?
      firstname
    elsif lastname.present?
      lastname
    else
      "Client"
    end
  end
end
