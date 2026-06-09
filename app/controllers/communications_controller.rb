class CommunicationsController < ApplicationController
  before_action :set_order
  before_action :set_communication, only: [:update]

  def create
    if params[:channel] == "sms"
      create_sms_communication
    else
      create_ai_client_message
    end
  end

  def update
    case params[:communication_action]
    when "regenerate"
      regenerate_ai_message
    when "save"
      save_ai_message
    when "send"
      mark_ai_message_as_sent
    else
      redirect_to order_path(@order, open_ai_message: "1"),
                  alert: "Action inconnue.",
                  status: :see_other
    end
  rescue StandardError => e
    redirect_to order_path(@order, open_ai_message: "1"),
                alert: "Action impossible : #{e.message}",
                status: :see_other
  end

  private

  def set_order
    @order = current_establishment.orders.find(params[:order_id])
  end

  def set_communication
    @communication = @order.communications.find(params[:id])
  end

  def communication_params
    params.require(:communication).permit(:kind, :subject, :body)
  end

  def create_ai_client_message
    content = AiClientMessageGenerator.new(
      order: @order,
      kind: communication_params[:kind]
    ).call

    @order.communications.create!(
      kind: communication_params[:kind],
      channel: "email",
      status: "pending",
      purpose: "ai_client_message",
      recipient_email: @order.customer&.email,
      content: content
    )

    redirect_to order_path(@order, open_ai_message: "1"), status: :see_other
  rescue StandardError => e
    redirect_to order_path(@order, open_ai_message: "1"),
                alert: "Impossible de générer le message IA : #{e.message}",
                status: :see_other
  end

  def regenerate_ai_message
    content = AiClientMessageGenerator.new(
      order: @order,
      kind: @communication.kind
    ).call

    @communication.update!(
      content: content,
      status: "pending",
      sent_at: nil
    )

    redirect_to order_path(@order, open_ai_message: "1"), status: :see_other
  end

  def save_ai_message
    @communication.update!(
      content: rebuilt_content,
      status: "pending",
      sent_at: nil
    )

    redirect_to order_path(@order, open_ai_message: "1"), status: :see_other
  end

  def mark_ai_message_as_sent
    @communication.update!(
      status: "sent",
      sent_at: Time.current
    )

    redirect_to order_path(@order, open_ai_message: "1"), status: :see_other
  end

  def rebuilt_content
    subject = communication_params[:subject].to_s.strip
    body = communication_params[:body].to_s.strip

    if subject.present?
      "Objet : #{subject}\n\n#{body}"
    else
      body
    end
  end

  def create_sms_communication
    if @order.notify_ready_by_sms!
      head :ok
    else
      head :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("Erreur SMS communication : #{e.message}")
    head :unprocessable_entity
  end
end
