# Totaux et libellés d'une commande, calculés à la volée depuis les order_lines
# (la table `orders` ne stocke pas les montants).
module OrderTotals
  extend ActiveSupport::Concern

  PAYMENT_METHOD_LABELS = {
    "cash"  => "Espèces",
    "card"  => "Carte",
    "check" => "Chèque"
  }.freeze

  # Total hors taxes — somme du HT de chaque ligne.
  def subtotal_ht
    order_lines.sum(&:total_ht)
  end
  alias_method :total_ht, :subtotal_ht

  # Montant de TVA, calculé ligne par ligne pour gérer des taux différents.
  def vat_amount
    order_lines.sum { |line| line.total_ht * line.vat_rate.to_f / 100 }
  end

  # Total TTC = HT + TVA (cohérent avec OrderLine#total_ttc).
  def total_ttc
    subtotal_ht + vat_amount
  end

  def payment_method_label
    PAYMENT_METHOD_LABELS.fetch(
      payment_method.to_s.downcase,
      payment_method.to_s.titleize.presence
    )
  end

  def payment_status_label
    payment_status == "paid" ? "Payé" : "À régler au retrait"
  end

  # Commande encore en cours dont la date de retrait est dépassée.
  def overdue?
    status == "in_progress" && due_date.present? && due_date < Date.today
  end
end
