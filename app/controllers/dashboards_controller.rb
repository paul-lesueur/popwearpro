class DashboardsController < ApplicationController
  PERIOD_OPTIONS = {
    "today"    => "Aujourd'hui",
    "week"     => "Cette semaine",
    "month"    => "Ce mois-ci",
    "quarter"  => "3 derniers mois",
    "semester" => "6 derniers mois",
    "year"     => "Cette année"
  }.freeze

  def show
    @establishment = current_establishment

    @orders = @establishment.orders.includes(:customer, :order_lines)
    @customers = @establishment.customers.named
    @items = @establishment.items

    @period_options = PERIOD_OPTIONS
    @period = PERIOD_OPTIONS.key?(params[:period]) ? params[:period] : "month"
    @period_label = PERIOD_OPTIONS[@period]

    start_date, end_date = period_range(@period)
    @period_orders = @orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    @orders_in_progress = @orders.where(status: ["pending", "in_progress"])
    @urgent_orders = @orders.select(&:urgent?)
    @completed_orders = @orders.where(status: "completed")
    @paid_orders = @orders.select(&:paid?)

    @revenue = @paid_orders.sum(&:total_ttc)

    @recent_orders = @orders.order(created_at: :desc).limit(5)
    @recent_customers = @customers.order(created_at: :desc).limit(5)
  end

  private

  def period_range(period)
    case period
    when "today"
      [Date.current, Date.current]
    when "week"
      start_date = Date.current.beginning_of_week(:monday)
      [start_date, start_date + 6.days]
    when "month"
      [Date.current.beginning_of_month, Date.current.end_of_month]
    when "quarter"
      [3.months.ago.to_date, Date.current]
    when "semester"
      [6.months.ago.to_date, Date.current]
    when "year"
      [Date.current.beginning_of_year, Date.current.end_of_year]
    end
  end
end
