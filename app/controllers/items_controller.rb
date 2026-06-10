class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items_per_page = 9

    @page = params[:page].to_i
    @page = 1 if @page < 1

    items_scope = current_establishment.items.order(created_at: :desc)

    @total_items = items_scope.count
    @total_pages = (@total_items.to_f / @items_per_page).ceil

    @page = @total_pages if @total_pages.positive? && @page > @total_pages

    @items = items_scope
      .offset((@page - 1) * @items_per_page)
      .limit(@items_per_page)
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
