class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :move]
  before_action :set_form_data, only: [:new, :create, :edit, :update]

  KANBAN_COLUMNS = [
    { key: "new",         label: "Nouvelles commandes",       statuses: %w[draft pending],       target_status: "pending" },
    { key: "in_progress", label: "En cours",                  statuses: %w[in_progress],         target_status: "in_progress" },
    { key: "recollect",   label: "En attente de re-collecte", statuses: %w[sent],                target_status: "sent" },
    { key: "done",        label: "Terminées",                 statuses: %w[completed delivered], target_status: "completed" }
  ].freeze

  ALLOWED_STATUSES = KANBAN_COLUMNS.map { |col| col[:target_status] }.freeze

  def index
    orders = current_establishment.orders
                                  .includes(:customer, order_lines: :item)
                                  .order(created_at: :desc)

    @columns = KANBAN_COLUMNS.map do |col|
      col.merge(orders: orders.select { |o| col[:statuses].include?(o.status) })
    end
  end

  def show
  end

  def new
    # Le formulaire de création (cartes + panier) ne demande pas le statut/la priorité :
    # on pose des valeurs par défaut. Les lignes sont ajoutées via le panier (Stimulus).
    @order = current_establishment.orders.new(status: "pending", priority: "medium", payment_status: "unpaid")
  end

  def create
    @order = current_establishment.orders.new(order_params)
    fill_order_line_prices

    if @order.save
      redirect_to @order, notice: "Commande créée avec succès."
    else
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

  def move
    status = params[:status]
    @order.update(status:) if ALLOWED_STATUSES.include?(status)
    head :ok
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
