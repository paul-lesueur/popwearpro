class CommunicationsController < ApplicationController
  def create
    order = current_establishment.orders.find(params[:order_id])
    communication = order.communications.create!(
      channel: "sms",
      status: "pending"
    )
    SendSmsJob.perform_later(communication.id)
    head :ok
  end
end
