class OrderMailer < ApplicationMailer
  default from: "Atelier Popwear <noreply@popwear.app>"

  # Email de confirmation brandé, reçu PDF en pièce jointe.
  def confirmation(order)
    @order         = order
    @customer      = order.customer
    @establishment = order.establishment
    @order_lines   = order.order_lines.includes(:item)

    attach_logo
    attach_receipt

    mail(
      to: @customer.email,
      subject: "Votre commande chez #{@establishment.name} est confirmée ✅"
    )
  end

  private

  # Logo embarqué en inline (cid:) : s'affiche sans dépendre d'images externes.
  def attach_logo
    path = Rails.root.join("app", "assets", "images", "logo-popwear-pro.png")
    attachments.inline["logo-popwear-pro.png"] = File.read(path)
  end

  def attach_receipt
    receipt = Receipts::Receipt.new(
      title: @order.document_label,
      company: {
        name: @establishment.name,
        address: @establishment.address.to_s,
        email: @establishment.user&.email.to_s
      },
      recipient: @customer.display_name,
      details: [
        ["#{@order.document_label} n°", @order.id],
        ["Date", I18n.l(@order.created_at.to_date, format: :long)]
      ],
      line_items: receipt_line_items
    )

    attachments["recu-commande-#{@order.id}.pdf"] = receipt.render
  end

  def receipt_line_items
    header = ["Désignation", "Qté", "PU HT", "TVA", "Total TTC"]

    rows = @order_lines.map do |line|
      [
        line.item&.name.presence || "Prestation",
        line.quantity,
        format_eur(line.unit_price_ht),
        "#{line.vat_rate.to_f.round} %",
        format_eur(line.total_ttc)
      ]
    end

    totals = [
      ["", "", "", "Total HT", format_eur(@order.subtotal_ht)],
      ["", "", "", "TVA", format_eur(@order.vat_amount)],
      ["", "", "", "Total TTC", format_eur(@order.total_ttc)]
    ]

    [header] + rows + totals
  end

  def format_eur(amount)
    ActiveSupport::NumberHelper.number_to_currency(
      amount, unit: "€", separator: ",", delimiter: " ", format: "%n %u"
    )
  end
end
