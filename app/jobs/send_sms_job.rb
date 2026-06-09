class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(communication_id)
    communication = Communication.find(communication_id)
    order = communication.order
    phone = order.customer.phone

    # Le message porté par la communication (rappel dédié, etc.) prime ; à défaut
    # on retombe sur le message « commande prête » par défaut.
    body = communication.content.presence ||
           "Bonjour #{order.customer.firstname}, votre commande CMD-#{order.id} est prête à être retirée chez Popwear."

    # En l'absence de configuration Twilio (dev / démo), on n'appelle pas l'API :
    # la communication est tout de même marquée envoyée pour garder l'UI,
    # l'historique et la déduplication cohérents. En prod (creds présents) → envoi réel.
    if twilio_configured?
      Twilio::REST::Client.new(
        ENV.fetch("TWILIO_ACCOUNT_SID", nil),
        ENV.fetch("TWILIO_AUTH_TOKEN", nil)
      ).messages.create(
        from: ENV.fetch("TWILIO_FROM_WHATSAPP", nil),
        to: "whatsapp:#{format_phone(phone)}",
        body: body
      )
    else
      Rails.logger.info("[SendSmsJob] Twilio non configuré — SMS simulé pour communication ##{communication.id}.")
    end

    communication.update!(status: "sent", sent_at: Time.current)
  end

  private

  def twilio_configured?
    ENV["TWILIO_ACCOUNT_SID"].present? &&
      ENV["TWILIO_AUTH_TOKEN"].present? &&
      ENV["TWILIO_FROM_WHATSAPP"].present?
  end

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
