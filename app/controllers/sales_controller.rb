require "csv"

class SalesController < ApplicationController
  before_action :authenticate_user!

  helper_method :order_reference,
                :customer_name,
                :payment_method_label,
                :payment_status_label,
                :line_total_ttc,
                :order_total_ttc

  def index
    @period_options = period_options
    @period = @period_options.key?(params[:period]) ? params[:period] : "month"
    @period_label = @period_options[@period]
    @previous_period_label = previous_period_label(@period)

    @all_orders = sales_orders
    @orders = filter_orders_by_dashboard_period(@all_orders, @period)
    @previous_orders = filter_orders_by_previous_dashboard_period(@all_orders, @period)

    @items_count = current_establishment.present? ? current_establishment.items.count : 0

    @total_sales = @orders.to_a.sum { |order| order_total_ttc(order) }
    @orders_count = @orders.count
    @average_order = @orders_count.positive? ? @total_sales / @orders_count : 0

    week_start = Date.current.beginning_of_week(:monday)

    @weekly_sales = (0..6).map do |index|
      date = week_start + index.days
      day_orders = @all_orders.where(created_at: date.beginning_of_day..date.end_of_day)

      {
        day: %w[L M M J V S D][index],
        value: day_orders.to_a.sum { |order| order_total_ttc(order) },
        count: day_orders.count
      }
    end

    @weekly_total = @weekly_sales.sum { |sale| sale[:value] }
    @weekly_orders_count = @weekly_sales.sum { |sale| sale[:count] }

    current_start_date, current_end_date = dashboard_period_range(@period)
    previous_start_date, previous_end_date = previous_dashboard_period_range(@period)

    @current_period_orders_count = @orders.count
    @previous_period_orders_count = @previous_orders.count

    @current_period_points = chart_points_for_range(@orders, current_start_date, current_end_date)
    @previous_period_points = chart_points_for_range(@previous_orders, previous_start_date || current_start_date, previous_end_date || current_end_date)

    @best_period_day = best_day_for(@orders, current_start_date, current_end_date)
    @best_sales = build_best_sales

    @services_percentage, @articles_percentage = sales_split_percentages
  end

  def transactions
    @query = params[:query].to_s.strip
    @export_start_date = params[:start_date].presence
    @export_end_date = params[:end_date].presence

    @transactions = build_transactions(sales_orders.order(created_at: :desc))
    @transactions = filter_transactions(@transactions, @query)

    @transactions_by_date = @transactions.group_by { |transaction| transaction[:date].to_date }
    @transactions_count = @transactions.count

    @selected_order = sales_orders.find_by(id: params[:order_id]) if params[:order_id].present?
  end

  def report
    query = params[:query].to_s.strip
    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])

    orders = sales_orders.order(created_at: :desc)
    orders = filter_orders_by_date_range(orders, start_date, end_date)

    transactions = build_transactions(orders)
    transactions = filter_transactions(transactions, query)

    csv = CSV.generate(col_sep: ";", headers: true) do |csv|
      csv << [
        "Date",
        "Référence",
        "Client",
        "Prix TTC",
        "Mode de paiement",
        "Statut paiement"
      ]

      transactions.each do |transaction|
        order = transaction[:order]

        csv << [
          I18n.l(transaction[:date], format: "%d/%m/%Y %H:%M"),
          transaction[:reference],
          transaction[:customer_name],
          helpers.number_to_currency(transaction[:total], unit: "€", separator: ",", delimiter: " ", format: "%n %u"),
          transaction[:payment_method],
          payment_status_label(order.payment_status)
        ]
      end
    end

    send_data(
      "\uFEFF#{csv}",
      filename: report_filename(start_date, end_date),
      type: "text/csv; charset=utf-8"
    )
  end

  private

  def sales_orders
    return Order.none if current_establishment.blank?

    current_establishment.orders.includes(:customer, order_lines: :item)
  end

  def period_options
    {
      "today" => "Aujourd’hui",
      "week" => "Cette semaine",
      "month" => "Ce mois-ci",
      "quarter" => "3 derniers mois",
      "semester" => "6 derniers mois",
      "year" => "Cette année",
      "all" => "Tout"
    }
  end

  def dashboard_period_range(period)
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
    else
      first_order_date = @all_orders.minimum(:created_at)&.to_date || Date.current
      [first_order_date, Date.current]
    end
  end

  def previous_dashboard_period_range(period)
    case period
    when "today"
      yesterday = Date.current - 1.day
      [yesterday, yesterday]
    when "week"
      start_date = Date.current.beginning_of_week(:monday) - 7.days
      [start_date, start_date + 6.days]
    when "month"
      previous_month = 1.month.ago.to_date
      [previous_month.beginning_of_month, previous_month.end_of_month]
    when "quarter"
      [6.months.ago.to_date, 3.months.ago.to_date - 1.day]
    when "semester"
      [12.months.ago.to_date, 6.months.ago.to_date - 1.day]
    when "year"
      previous_year = 1.year.ago.to_date
      [previous_year.beginning_of_year, previous_year.end_of_year]
    else
      [nil, nil]
    end
  end

  def previous_period_label(period)
    case period
    when "today"
      "Hier"
    when "week"
      "Semaine précédente"
    when "month"
      "Mois précédent"
    when "quarter"
      "3 mois précédents"
    when "semester"
      "6 mois précédents"
    when "year"
      "Année précédente"
    else
      "Comparaison"
    end
  end

  def filter_orders_by_dashboard_period(orders, period)
    start_date, end_date = dashboard_period_range(period)
    orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  end

  def filter_orders_by_previous_dashboard_period(orders, period)
    start_date, end_date = previous_dashboard_period_range(period)

    return Order.none if start_date.blank? || end_date.blank?

    orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  end

  def build_transactions(orders)
    orders.map do |order|
      {
        order: order,
        date: order.created_at,
        reference: "Commande #{order_reference(order)}",
        customer_name: customer_name(order.customer),
        payment_method: payment_method_label(order.payment_method),
        payment_status: payment_status_label(order.payment_status),
        total: order_total_ttc(order)
      }
    end
  end

  def filter_transactions(transactions, query)
    return transactions if query.blank?

    transactions.select do |transaction|
      [
        transaction[:reference],
        transaction[:customer_name],
        transaction[:payment_method],
        transaction[:payment_status],
        transaction[:total].to_s
      ].any? { |value| value.downcase.include?(query.downcase) }
    end
  end

  def filter_orders_by_date_range(orders, start_date, end_date)
    if start_date.present? && end_date.present?
      orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    elsif start_date.present?
      orders.where(created_at: start_date.beginning_of_day..)
    elsif end_date.present?
      orders.where(created_at: ..end_date.end_of_day)
    else
      orders
    end
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def report_filename(start_date, end_date)
    if start_date.present? && end_date.present?
      "rapport-ventes-#{start_date.strftime('%Y-%m-%d')}-au-#{end_date.strftime('%Y-%m-%d')}.csv"
    elsif start_date.present?
      "rapport-ventes-depuis-#{start_date.strftime('%Y-%m-%d')}.csv"
    elsif end_date.present?
      "rapport-ventes-jusquau-#{end_date.strftime('%Y-%m-%d')}.csv"
    else
      "rapport-ventes-#{Date.current.strftime('%Y-%m-%d')}.csv"
    end
  end

  def order_total_ttc(order)
    lines_total = order.order_lines.to_a.sum do |line|
      line_total_ttc(line)
    end

    total = lines_total - order.discount.to_f
    total.positive? ? total : 0
  end

  def line_total_ttc(line)
    quantity = line.quantity.to_i
    quantity = 1 if quantity.zero?

    unit_price_ht = line.unit_price_ht.to_f
    vat_rate = line.vat_rate.to_f

    total_ht = quantity * unit_price_ht
    total_ht * (1 + vat_rate / 100)
  end

  def customer_name(customer)
    return "Client anonyme" if customer.blank? || customer.is_anonymous?

    name = [customer.firstname, customer.lastname].compact.join(" ").strip
    name.presence || customer.email.presence || customer.phone.presence || "Client"
  end

  def order_reference(order)
    alphabet = ("A".."Z").to_a
    first_letter = alphabet[order.id.to_i % 26]
    second_letter = alphabet[(order.id.to_i / 26) % 26]
    number = order.id.to_s.rjust(6, "0")

    "#{first_letter}#{second_letter}#{number}"
  end

  def payment_method_label(payment_method)
    case payment_method.to_s.downcase
    when "card", "carte", "carte_bancaire", "cb", "carte bancaire"
      "Carte bancaire"
    when "cash", "especes", "espèces"
      "Espèces"
    when "check", "cheque", "chèque"
      "Chèque"
    else
      payment_method.present? ? payment_method.humanize : "Non renseigné"
    end
  end

  def payment_status_label(payment_status)
    case payment_status.to_s.downcase
    when "paid", "payé", "paye"
      "Payé"
    when "pending", "waiting", "en_attente"
      "En attente"
    when "unpaid", "not_paid", "non_paye", "non payé"
      "Non payé"
    when "partial", "partially_paid"
      "Partiellement payé"
    when "refunded", "rembourse", "remboursé"
      "Remboursé"
    when "failed", "error", "declined"
      "Paiement échoué"
    else
      "Statut non renseigné"
    end
  end

  def build_best_sales
    sales = Hash.new do |hash, item_id|
      hash[item_id] = {
        item: nil,
        units: 0,
        total: 0
      }
    end

    @orders.find_each do |order|
      order.order_lines.includes(:item).each do |line|
        item = line.item
        next if item.blank?

        quantity = line.quantity.to_i
        quantity = 1 if quantity.zero?

        sales[item.id][:item] = item
        sales[item.id][:units] += quantity
        sales[item.id][:total] += line_total_ttc(line)
      end
    end

    sales.values
         .sort_by { |sale| -sale[:units] }
         .first(5)
         .map do |sale|
           item = sale[:item]

           {
             name: item.name,
             price: item.price_ht.to_f,
             units: sale[:units],
             total: sale[:total],
             icon: item.icon
           }
         end
  end

  def sales_split_percentages
    services_count = 0
    articles_count = 0

    @orders.find_each do |order|
      order.order_lines.includes(:item).each do |line|
        item = line.item
        next if item.blank?

        quantity = line.quantity.to_i
        quantity = 1 if quantity.zero?

        if service_item?(item)
          services_count += quantity
        else
          articles_count += quantity
        end
      end
    end

    total = services_count + articles_count
    return [0, 0] if total.zero?

    services_percentage = ((services_count.to_f / total) * 100).round
    articles_percentage = 100 - services_percentage

    [services_percentage, articles_percentage]
  end

  def service_item?(item)
    return true if item.repair_bonus == true

    name = item.name.to_s.downcase

    service_keywords = [
      "retouche",
      "ourlet",
      "réparation",
      "reparation",
      "cordonnerie",
      "ressemelage",
      "talon",
      "semelle",
      "pose",
      "couture",
      "nettoyage"
    ]

    service_keywords.any? { |keyword| name.include?(keyword) }
  end

  def chart_points_for_range(scope, start_date, end_date)
    start_date ||= Date.current
    end_date ||= Date.current

    days = (start_date..end_date).to_a
    days = [Date.current] if days.empty?

    values = days.map do |date|
      scope.where(created_at: date.beginning_of_day..date.end_of_day).count
    end

    max_value = values.max.to_i
    max_value = 1 if max_value.zero?

    width = 680.0
    height = 190.0
    step = days.size > 1 ? width / (days.size - 1) : width

    values.each_with_index.map do |value, index|
      x = (step * index).round
      y = (height - ((value.to_f / max_value) * 150)).round

      "#{x},#{y}"
    end.join(" ")
  end

  def best_day_for(scope, start_date, end_date)
    best_day = nil
    best_count = 0

    (start_date..end_date).each do |date|
      count = scope.where(created_at: date.beginning_of_day..date.end_of_day).count

      if count > best_count
        best_count = count
        best_day = date
      end
    end

    {
      date: best_day,
      count: best_count
    }
  end
end
