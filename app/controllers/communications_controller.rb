class CommunicationsController < ApplicationController
  before_action :set_order

  def create
    level = params[:reminder_level].to_i

    if Order::PICKUP_REMINDER_DAYS.include?(level)
      # UC3 — rappel « commande non retirée » (J+3 / J+10), depuis la modal.
      sent = @order.send_pickup_reminder!(level)
      @flash = reminder_flash(sent)
      respond_to do |format|
        format.turbo_stream { render "orders/update_modal" }
        format.html { redirect_to order_path(@order), flash: redirect_flash }
      end
    else
      # UC2 — SMS « commande prête » (bouton de la modal OU toast du kanban).
      sent = @order.notify_ready_by_sms!
      @flash = ready_flash(sent)
      respond_to do |format|
        format.turbo_stream { render "orders/update_modal" }
        format.json { render json: @flash } # toast kanban : { variant, message }
        format.html { redirect_to order_path(@order), flash: redirect_flash }
      end
    end
  end

  private

  def set_order
    @order = current_establishment.orders.find(params[:order_id])
  end

  def ready_flash(sent)
    if sent
      { variant: "success", message: "SMS « commande prête » envoyé au client." }
    elsif @order.customer.phone.blank?
      { variant: "info", message: "SMS non envoyé : le client n'a pas de téléphone." }
    else
      { variant: "info", message: "SMS « commande prête » déjà envoyé." }
    end
  end

  def reminder_flash(sent)
    if sent
      { variant: "success", message: "SMS de rappel de retrait envoyé au client." }
    elsif @order.customer.phone.blank?
      { variant: "info", message: "SMS de rappel non envoyé : le client n'a pas de téléphone." }
    else
      { variant: "info", message: "SMS de rappel déjà envoyé." }
    end
  end

  # Pour le fallback HTML (sans Turbo) : map la variante vers une clé de flash.
  def redirect_flash
    { @flash[:variant].to_sym => @flash[:message] }
  end
end
