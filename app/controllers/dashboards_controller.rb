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
    period_range_full = start_date.beginning_of_day..end_date.end_of_day
    @period_orders = @orders.where(created_at: period_range_full)

    # Indicateurs du bloc "Résumé de l'activité" : tous sensibles à la période choisie.
    @period_in_progress_count = @period_orders.where(status: ["pending", "in_progress"]).count
    @period_customers_count = @customers.where(created_at: period_range_full).count

    @orders_in_progress = @orders.where(status: ["pending", "in_progress"])
    @urgent_orders = @orders.select(&:urgent?)
    @completed_orders = @orders.where(status: "completed")
    @paid_orders = @orders.select(&:paid?)

    # "Votre journée" : chiffre d'affaires encaissé AUJOURD'HUI (commandes du jour payées).
    # Pas de date de paiement en base -> on se base sur created_at du jour.
    @revenue = @orders.where(created_at: Date.current.all_day).select(&:paid?).sum(&:total_ttc)

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
