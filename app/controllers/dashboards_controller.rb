class DashboardsController < ApplicationController
  def show
    @establishment = current_establishment

    @orders = @establishment.orders.includes(:customer, :order_lines)
    @customers = @establishment.customers.named # exclut les clients anonymes des stats
    @items = @establishment.items

    @orders_in_progress = @orders.where(status: ["pending", "in_progress"])
    @urgent_orders = @orders.select(&:urgent?)
    @completed_orders = @orders.where(status: "completed")
    @paid_orders = @orders.select(&:paid?)

    @revenue = @paid_orders.sum(&:total_ttc)

    @recent_orders = @orders.order(created_at: :desc).limit(5)
    @recent_customers = @customers.order(created_at: :desc).limit(5)
  end
end
