class ClientMessagesController < ApplicationController
  before_action :set_order

  def create
    content = AiClientMessageGenerator.new(
      order: @order,
      kind: client_message_params[:kind],
      tone: client_message_params[:tone]
    ).call

    @order.communications.create!(
      kind: client_message_params[:kind],
      channel: "email",
      status: "pending",
      purpose: "ai_client_message",
      recipient_email: @order.customer&.email,
      content: content
    )

    redirect_to order_path(@order), notice: "Message IA généré."
  rescue StandardError => e
    redirect_to order_path(@order), alert: "Impossible de générer le message IA : #{e.message}"
  end

  private

  def set_order
    @order = current_establishment.orders.find(params[:order_id])
  end

  def client_message_params
    params.require(:client_message).permit(:kind, :tone)
  end
end
