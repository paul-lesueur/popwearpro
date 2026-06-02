class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_form_data, only: [:new, :create, :edit, :update]

  def index
    @orders = current_establishment.orders
                                   .includes(:customer, :order_lines)
                                   .order(created_at: :desc)
  end

  def show
  end

  def new
    @order = current_establishment.orders.new
    3.times { @order.order_lines.build }
  end

  def create
    @order = current_establishment.orders.new(order_params)
    fill_order_line_prices

    if @order.save
      redirect_to @order, notice: "Commande créée avec succès."
    else
      3.times { @order.order_lines.build } if @order.order_lines.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @order.order_lines.build
  end

  def update
    @order.assign_attributes(order_params)
    fill_order_line_prices

    if @order.save
      redirect_to @order, notice: "Commande mise à jour avec succès."
    else
      @order.order_lines.build if @order.order_lines.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: "Commande supprimée avec succès."
  end

  private

  def set_order
    @order = current_establishment.orders.find(params[:id])
  end

  def set_form_data
    @customers = current_establishment.customers.order(:lastname, :firstname)
    @items = current_establishment.items.where(active: true).order(:name)
  end

  def order_params
    params.require(:order).permit(
      :customer_id,
      :status,
      :priority,
      :due_date,
      :payment_method,
      :payment_status,
      :paid_at,
      :collected_at,
      :internal_notes,
      order_lines_attributes: [
        :id,
        :item_id,
        :quantity,
        :unit_price_ht,
        :vat_rate,
        :_destroy
      ]
    )
  end

  def fill_order_line_prices
    @order.order_lines.each do |line|
      next if line.item.blank?

      line.quantity = 1 if line.quantity.blank?
      line.unit_price_ht = line.item.price_ht if line.unit_price_ht.blank?
      line.vat_rate = line.item.vat_rate if line.vat_rate.blank?
    end
  end
end
