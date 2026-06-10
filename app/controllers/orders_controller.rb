class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :move, :unarchive, :reschedule, :toggle_reminder]
  before_action :set_form_data, only: [:new, :create, :edit, :update]

  KANBAN_COLUMNS = [
    { key: "new",         label: "Nouvelles commandes",       statuses: %w[pending],             target_status: "pending" },
    { key: "in_progress", label: "En cours",                  statuses: %w[in_progress],         target_status: "in_progress" },
    { key: "recollect",   label: "En attente de retrait", statuses: %w[sent],                target_status: "sent" },
    { key: "done",        label: "Terminées",                 statuses: %w[completed delivered], target_status: "completed" }
  ].freeze

  ALLOWED_STATUSES = KANBAN_COLUMNS.map { |col| col[:target_status] }.freeze

  def index
    Order.auto_archive_done!(current_establishment)

    orders = current_establishment.orders
                                  .not_archived
                                  .includes(:customer, :communications, order_lines: :item)
                                  .order(created_at: :desc)

    @search_query = params[:q].to_s.strip
    if @search_query.present?
      pattern = "%#{@search_query.downcase}%"
      orders = orders.joins(:customer).where(
        "LOWER(customers.firstname || ' ' || customers.lastname) LIKE :q OR CAST(orders.id AS TEXT) LIKE :q",
        q: pattern
      )
    end

    @archived_count = current_establishment.orders.archived.count

    @columns = KANBAN_COLUMNS.map do |col|
      col.merge(orders: orders.select { |o| col[:statuses].include?(o.status) })
    end
  end

  def show
  end

  def new
    # Le formulaire de création (cartes + panier) ne demande pas le statut/la priorité :
    # on pose des valeurs par défaut. Les lignes sont ajoutées via le panier (Stimulus).
    @order = current_establishment.orders.new(status: "pending", payment_status: "unpaid")
  end

  def create
    @order = current_establishment.orders.new(order_params)
    assign_customer
    fill_order_line_prices

    if @order.save
      redirect_to confirmation_order_path(@order)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Écran "Commande validée" affiché après création.
  def confirmation
    @order = current_establishment.orders.find(params[:id])
  end

  def edit
    @order.order_lines.build
  end

  def update
    @order.assign_attributes(order_params)
    fill_order_line_prices

    if @order.save
      redirect_to orders_path(open: @order.id), notice: "Commande mise à jour avec succès."
    else
      @order.order_lines.build if @order.order_lines.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def archives
    @archived_orders = current_establishment.orders
                                            .archived
                                            .includes(:customer, order_lines: :item)
                                            .order(archived_at: :desc)
  end

  def unarchive
    @order.unarchive!
    redirect_to archives_orders_path, notice: "Commande remise dans les terminées."
  end

  def move
    status = params[:status]
    @order.update(status:) if ALLOWED_STATUSES.include?(status)
    head :ok
  end

  # Replanifie la date de retrait. SMS envoyé uniquement si la nouvelle date est
  # un vrai report (postérieure à l'ancienne). Réponse Turbo Stream (fluide).
  def reschedule
    # Parsing strict ISO (format du date_field) : rejette les dates laxistes
    # ("2026" -> mois/jour courants) ou malformées sans lever d'exception non gérée.
    new_date = begin
      params[:due_date].present? ? Date.iso8601(params[:due_date].to_s) : nil
    rescue ArgumentError, TypeError
      nil
    end

    @flash =
      if new_date.nil?
        { variant: "error", message: "Indiquez une date de retrait valide." }
      else
        reschedule_flash(@order.reschedule_and_notify!(new_date))
      end

    respond_to do |format|
      format.turbo_stream { render "orders/update_modal" }
      format.html { redirect_to order_path(@order), flash: { @flash[:variant].to_sym => @flash[:message] } }
    end
  end

  # Active/désactive le rappel SMS pour cette commande (toggle du drawer).
  def toggle_reminder
    @order.update(sms_reminder: !@order.sms_reminder)
    redirect_to order_path(@order)
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: "Commande supprimée avec succès."
  end

  private

  def reschedule_flash(sms)
    if sms
      { variant: "success", message: "Date de retrait mise à jour. SMS envoyé au client." }
    elsif @order.customer.phone.blank?
      { variant: "info", message: "Date de retrait mise à jour. SMS non envoyé : pas de téléphone." }
    else
      { variant: "info", message: "Date de retrait mise à jour. (Date non reportée — aucun SMS.)" }
    end
  end

  def set_order
    @order = current_establishment.orders.find(params[:id])
  end

  def set_form_data
    # On n'affiche QUE les clients nommés dans le menu déroulant (jamais les anonymes).
    @customers = current_establishment.customers.named.order(:lastname, :firstname)
    @items = current_establishment.items.where(active: true).order(:name)
  end

  # Rattachement du client selon le mode choisi dans le wizard (étape 1).
  # - passage  : client anonyme (ANON-xxxxx), sans identité -> donne un reçu.
  # - new      : on crée une fiche client à partir du nom/tél/email saisis.
  # - existing : le customer_id est déjà dans order_params.
  # L'autosave de belongs_to crée le client dans la même transaction que la commande.
  def assign_customer
    case params.dig(:order, :client_mode)
    when "passage"
      @order.customer = current_establishment.customers.new(is_anonymous: true)
    when "new"
      @order.customer = build_new_customer
    end
  end

  def build_new_customer
    full = params.dig(:order, :new_name).to_s.strip
    first, *rest = full.split(/\s+/)
    current_establishment.customers.new(
      firstname: first.presence || full,
      lastname:  rest.join(" ").presence || first.presence || full,
      phone:     params.dig(:order, :new_phone).presence,
      email:     params.dig(:order, :new_email).presence
    )
  end

  def order_params
    params.require(:order).permit(
      :customer_id,
      :status,
      :due_date,
      :payment_method,
      :payment_status,
      :paid_at,
      :collected_at,
      :internal_notes,
      :discount,
      :email_confirmation,
      :sms_reminder,
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
