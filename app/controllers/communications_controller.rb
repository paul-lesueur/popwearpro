class CommunicationsController < ApplicationController
  def create
    order = current_establishment.orders.find(params[:order_id])

    level = params[:reminder_level].to_i
    if Order::PICKUP_REMINDER_DAYS.include?(level)
      # Rappel « commande non retirée » déclenché depuis la fiche commande.
      order.send_pickup_reminder!(level)
      redirect_to order_path(order)
    else
      # Envoi SMS « commande prête » déclenché depuis le kanban (toast).
      communication = order.communications.create!(channel: "sms", status: "pending")
      SendSmsJob.perform_later(communication.id)
      head :ok
    end
  end
end
