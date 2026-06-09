class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(communication_id)
    communication = Communication.find(communication_id)
    order = communication.order
    phone = order.customer.phone

    client = Twilio::REST::Client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID", nil),
      ENV.fetch("TWILIO_AUTH_TOKEN", nil)
    )

    # Le message porté par la communication (rappel dédié, etc.) prime ; à défaut
    # on retombe sur le message « commande prête » par défaut.
    body = communication.content.presence ||
           "Bonjour #{order.customer.firstname}, votre commande CMD-#{order.id} est prête à être retirée chez Popwear."

    client.messages.create(
      from: ENV.fetch("TWILIO_FROM_WHATSAPP", nil),
      to: "whatsapp:#{format_phone(phone)}",
      body: body
    )

    communication.update!(status: "sent", sent_at: Time.current)
  end

  private

  def format_phone(number)
    number = number.gsub(/\s/, '')
    if number.start_with?('0')
      "+33#{number[1..]}"
    elsif number.start_with?('+')
      number
    else
      "+33#{number}"
    end
  end
end
