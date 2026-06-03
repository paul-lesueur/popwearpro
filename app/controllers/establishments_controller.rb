class EstablishmentsController < ApplicationController
  before_action :set_establishment

  def show
  end

  def edit
  end

  def update
    if @establishment.update(establishment_params)
      redirect_to establishment_path, notice: "Établissement mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_establishment
    @establishment = current_establishment
  end

  def establishment_params
    permitted_params = params.require(:establishment).permit(
      :name,
      :description,
      :address,
      :category,
      :opening_hours,
      :siret_siren,
      :photo,
      payment_methods: []
    )

    if permitted_params[:payment_methods].is_a?(Array)
      permitted_params[:payment_methods] = permitted_params[:payment_methods]
                                           .reject(&:blank?)
                                           .join(", ")
    end

    permitted_params
  end
end
