class AiClientMessageGenerator
  def initialize(order:, kind:)
    @order = order
    @kind = kind
    @customer = order.customer
    @establishment = order.establishment
  end

  def call
    response = RubyLLM.chat(model: "gpt-4o-mini").ask(prompt)

    if response.respond_to?(:content)
      response.content.to_s.strip
    else
      response.to_s.strip
    end
  end

  private

  def prompt
    <<~PROMPT
      Tu es l'assistant IA de Popwear Pro, une application de gestion pour artisans.

      Tu dois rédiger un message client court, clair, professionnel et prêt à envoyer.

      Contexte de la commande :
      - Atelier : #{establishment_name}
      - Client : #{customer_name}
      - Type de message : #{kind_label}
      - Numéro de commande : #{@order.id}
      - Statut de commande : #{@order.status}
      - Date de retrait prévue : #{formatted_due_date}
      - Prestations : #{order_lines_summary}
      - Total : #{formatted_total}

      Contraintes :
      - Réponds en français.
      - Ne mentionne jamais l'IA.
      - Ne mets aucun placeholder.
      - Ne dis pas que le client peut répondre directement au mail.
      - Le message doit être court.
      - Le ton doit être professionnel, naturel et rassurant.
      - Termine avec la signature de l'atelier.
      - Réponds uniquement avec le message final.

      Format attendu :

      Objet : ...

      Bonjour ...

      ...
    PROMPT
  end

  def customer_name
    return "client" unless @customer.present?

    "#{@customer.firstname} #{@customer.lastname}".strip.presence || "client"
  end

  def establishment_name
    @establishment&.name.presence || "L’atelier"
  end

  def kind_label
    case @kind
    when "ready"
      "commande prête à être retirée"
    when "retard"
      "retard sur la commande"
    when "information_needed"
      "demande d'information complémentaire au client"
    else
      "message concernant la commande"
    end
  end

  def formatted_due_date
    return "non renseignée" unless @order.due_date.present?

    @order.due_date.strftime("%d/%m/%Y")
  end

  def formatted_total
    "#{@order.total_due.round(2)} €"
  end

  def order_lines_summary
    lines = @order.order_lines.map do |line|
      item_name = line.item&.name
      quantity = line.quantity.presence || 1

      "#{quantity} x #{item_name}" if item_name.present?
    end

    lines.compact.join(", ").presence || "non renseignées"
  end
end
