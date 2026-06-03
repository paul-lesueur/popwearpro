class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = current_establishment.items.order(created_at: :desc)
  end

  def show
  end

  def new
    @item = current_establishment.items.new
  end

  def create
    @item = current_establishment.items.new(item_params)

    if @item.save
      redirect_to @item, notice: "Élément ajouté au catalogue."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Élément mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "Élément supprimé."
  end

  private

  def set_item
    @item = current_establishment.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(
      :name,
      :price_ht,
      :vat_rate,
      :repair_bonus,
      :photo_url,
      :active
    )
  end
end
