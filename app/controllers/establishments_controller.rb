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
    @establishment = current_user.establishment

    return if @establishment.present?

    @establishment = current_user.create_establishment!(
      name: "Mon atelier",
      description: "Description à compléter",
      address: "Adresse à compléter",
      category: "couture",
      payment_methods: "Carte bancaire, espèces, virement",
      opening_hours: "Horaires à compléter",
      siret_siren: "À compléter"
    )
  end

  def establishment_params
    params.require(:establishment).permit(
      :name,
      :description,
      :address,
      :category,
      :payment_methods,
      :opening_hours,
      :siret_siren
    )
  end
end
