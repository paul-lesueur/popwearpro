class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]

  SORT_COLUMNS = %w[lastname email created_at orders_count].freeze
  CUSTOMERS_PER_PAGE = 10

  def index
    base_customers = current_establishment
                     .customers
                     .named

    @customers_count = base_customers.count

    @new_customers_this_month = base_customers
                                .where("customers.created_at >= ?", Time.current.beginning_of_month)
                                .count

    customers = base_customers
                .left_joins(:orders)
                .select("customers.*, COUNT(orders.id) AS orders_count")
                .group("customers.id")

    if params[:query].present?
      query = params[:query].strip
      search_query = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      search_query_without_spaces = "%#{ActiveRecord::Base.sanitize_sql_like(query.delete(' '))}%"

      customers = customers.where(
        <<~SQL,
          customers.firstname ILIKE :query
          OR customers.lastname ILIKE :query
          OR customers.email ILIKE :query
          OR customers.phone ILIKE :query
          OR REPLACE(customers.phone, ' ', '') ILIKE :query_without_spaces
          OR CONCAT(customers.firstname, ' ', customers.lastname) ILIKE :query
          OR CONCAT(customers.lastname, ' ', customers.firstname) ILIKE :query
        SQL
        query: search_query,
        query_without_spaces: search_query_without_spaces
      )
    end

    customers = sort_customers(customers)

    @page = params[:page].to_i
    @page = 1 if @page < 1

    @customers_total = customers.length
    @total_pages = (@customers_total.to_f / CUSTOMERS_PER_PAGE).ceil
    @total_pages = 1 if @total_pages < 1

    @page = @total_pages if @page > @total_pages

    @customers = customers
                 .offset((@page - 1) * CUSTOMERS_PER_PAGE)
                 .limit(CUSTOMERS_PER_PAGE)
                 .preload(:orders)
  end

  def show
  end

  def new
    @customer = current_establishment.customers.new
  end

  def create
    @customer = current_establishment.customers.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: "Client créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Client mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_path, notice: "Client supprimé avec succès."
  end

  private

  def set_customer
    @customer = current_establishment.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:firstname, :lastname, :email, :phone, :notes)
  end

  def sort_customers(customers)
    direction = sort_direction.upcase

    case sort_column
    when "lastname"
      customers.reorder(Arel.sql("LOWER(customers.lastname) #{direction}, LOWER(customers.firstname) #{direction}"))
    when "email"
      customers.reorder(Arel.sql("LOWER(customers.email) #{direction}"))
    when "orders_count"
      customers.reorder(Arel.sql("COUNT(orders.id) #{direction}"))
    else
      customers.reorder(Arel.sql("customers.created_at #{direction}"))
    end
  end

  def sort_column
    SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    params[:direction] == "asc" ? "asc" : "desc"
  end
end
