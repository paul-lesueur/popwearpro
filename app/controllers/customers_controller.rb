class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @customers = current_establishment.customers.order(created_at: :desc)
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
end
