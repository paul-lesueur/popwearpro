module CustomersHelper
  def customer_order_status_class(status)
    case status.to_s
    when "new"
      "customer-badge customer-badge--new"
    when "pending"
      "customer-badge customer-badge--pending"
    when "in_progress"
      "customer-badge customer-badge--in-progress"
    when "recollect"
      "customer-badge customer-badge--recollect"
    when "done", "completed"
      "customer-badge customer-badge--done"
    when "delivered"
      "customer-badge customer-badge--delivered"
    when "sent"
      "customer-badge customer-badge--sent"
    when "cancelled"
      "customer-badge customer-badge--cancelled"
    else
      "customer-badge customer-badge--neutral"
    end
  end

  def customer_payment_status_class(payment_status)
    case payment_status.to_s
    when "paid", "card", "carte", "cb", "credit_card", "payment_card", "paiement_carte"
      "customer-badge customer-badge--payment-card"
    when "cash", "especes", "espèces", "payment_cash", "paiement_especes"
      "customer-badge customer-badge--payment-cash"
    when "unpaid", "not_paid", "non_paye", "non_payé", "non payé"
      "customer-badge customer-badge--unpaid"
    when "pending", "waiting", "en_attente", "en attente"
      "customer-badge customer-badge--payment-pending"
    when "partial", "partiel", "partially_paid"
      "customer-badge customer-badge--partial"
    when "refunded", "rembourse", "remboursé"
      "customer-badge customer-badge--refunded"
    when "cancelled", "annule", "annulé"
      "customer-badge customer-badge--cancelled"
    else
      "customer-badge customer-badge--neutral"
    end
  end
end
