# db/seeds.rb
# Seed demo PopWearPro — focus cordonnier
# Warning: resets demo data.

ActionMailer::Base.perform_deliveries = false

puts "Cleaning database..."

Communication.destroy_all
OrderLine.destroy_all
Order.destroy_all
Item.destroy_all
Customer.destroy_all
Establishment.destroy_all
User.destroy_all

puts "Creating user..."

user = User.create!(
  email: "demo@popwearpro.com",
  password: "password",
  name: "Claude Codin"
)

puts "Creating establishment..."

establishment = Establishment.create!(
  user: user,
  name: "Atelier Claude",
  description: "Atelier de cordonnerie artisanale spécialisé dans la réparation, l’entretien et la rénovation de chaussures et articles en cuir.",
  address: "12 rue des Artisans, 75011 Paris",
  category: "Cordonnier",
  payment_methods: "Carte bancaire, espèces, chèque",
  opening_hours: "Lundi au samedi, 9h30 - 18h30",
  siret_siren: "12345678900012"
)

puts "Creating customers..."

customers_data = [
  ["Camille", "Martin", "camille.martin@email.com", "06 12 34 56 78", "Cliente régulière. Préfère être contactée par SMS."],
  ["Thomas", "Bernard", "thomas.bernard@email.com", "06 98 76 54 32", "Commandes souvent urgentes."],
  ["Sophie", "Leroy", "sophie.leroy@email.com", "07 22 44 66 88", "Aime les finitions premium."],
  ["Karim", "Benali", "karim.benali@email.com", "07 11 23 45 67", "Dépose souvent plusieurs articles."],
  ["Élise", "Robert", "elise.robert@email.com", "07 15 82 44 31", "Cliente régulière pour entretien cuir."],
  ["Hugo", "Renard", "hugo.renard@email.com", "07 12 89 45 67", "Sneakers et zip principalement."],
  ["Laura", "Simon", "laura.simon@email.com", "06 32 14 58 79", "Prévenir dès que la commande est prête."],
  ["Mehdi", "Kacem", "mehdi.kacem@email.com", "07 26 37 48 59", "Client régulier pour ressemelage."]
]

customers = customers_data.map do |firstname, lastname, email, phone, notes|
  Customer.create!(
    establishment: establishment,
    firstname: firstname,
    lastname: lastname,
    email: email,
    phone: phone,
    notes: notes
  )
end

puts "Creating catalog items..."

prestations = [
  { name: "Entretien cuir nettoyage & cirage", price_ht: 25, bonus: false, icon: "cirage" },
  { name: "Cirage & glaçage", price_ht: 29, bonus: false, icon: "cirage" },
  { name: "Rénovation complète cuir", price_ht: 55, bonus: false, icon: "finition" },
  { name: "Changement de lacets", price_ht: 5, bonus: false, icon: "reparer" },
  { name: "Pose de patins x2", price_ht: 26, bonus: true, icon: "patins-fers" },
  { name: "Pose de fers x2", price_ht: 21, bonus: false, icon: "patins-fers" },
  { name: "Mise en forme coup de pied", price_ht: 29, bonus: false, icon: "elargir" },
  { name: "Ressemelage caoutchouc", price_ht: 83, bonus: true, icon: "ressemelage" },
  { name: "Ressemelage sneakers", price_ht: 70, bonus: true, icon: "ressemelage" },
  { name: "Recollage semelle", price_ht: 30, bonus: true, icon: "ressemelage" },
  { name: "Bonbout talons aiguille", price_ht: 15, bonus: true, icon: "talon-bonbout" },
  { name: "Talon complet chaussures plates", price_ht: 65, bonus: false, icon: "talon-bonbout" },
  { name: "Trou avec rustine intérieure", price_ht: 20, bonus: true, icon: "dechirure" },
  { name: "Couture décousue", price_ht: 20, bonus: true, icon: "reparer" },
  { name: "Changement zip", price_ht: 45, bonus: true, icon: "zip" }
]

items_by_name = {}

prestations.each do |prest|
  items_by_name[prest[:name]] = establishment.items.create!(
    name: prest[:name],
    price_ht: prest[:price_ht],
    vat_rate: 20,
    repair_bonus: prest[:bonus],
    active: true,
    icon: prest[:icon]
  )
end

items = items_by_name.values

def create_order_with_lines!(
  establishment:,
  customer:,
  status:,
  priority:,
  created_at:,
  due_date:,
  payment_method:,
  payment_status:,
  paid_at: nil,
  collected_at: nil,
  internal_notes:,
  lines:
)
  order = Order.create!(
    establishment: establishment,
    customer: customer,
    status: status,
    priority: priority,
    due_date: due_date,
    payment_method: payment_method,
    payment_status: payment_status,
    paid_at: paid_at,
    collected_at: collected_at,
    internal_notes: internal_notes,
    created_at: created_at,
    updated_at: created_at
  )

  lines.each do |line|
    item = line[:item]

    OrderLine.create!(
      order: order,
      item: item,
      quantity: line[:quantity],
      unit_price_ht: item.price_ht,
      vat_rate: item.vat_rate,
      created_at: created_at,
      updated_at: created_at
    )
  end

  order
end

puts "Creating demo orders..."

notes = [
  "Prévenir le client dès que la commande est prête.",
  "Client pressé. Faire attention au délai.",
  "Vérifier la finition avant remise.",
  "Demande une finition propre et discrète.",
  "Commande déposée avec plusieurs articles."
]

created_orders = []

orders_data = [
  {
    customer: customers[0],
    status: "pending",
    priority: "high",
    days_ago: 0,
    due_in: 3,
    payment_method: "card",
    payment_status: "unpaid",
    lines: [["Pose de patins x2", 1], ["Cirage & glaçage", 1]]
  },
  {
    customer: customers[1],
    status: "in_progress",
    priority: "urgent",
    days_ago: 1,
    due_in: 1,
    payment_method: "cash",
    payment_status: "unpaid",
    lines: [["Ressemelage sneakers", 1]]
  },
  {
    customer: customers[2],
    status: "completed",
    priority: "medium",
    days_ago: 3,
    due_in: 0,
    payment_method: "card",
    payment_status: "paid",
    lines: [["Rénovation complète cuir", 1]]
  },
  {
    customer: customers[3],
    status: "sent",
    priority: "medium",
    days_ago: 5,
    due_in: -1,
    payment_method: "card",
    payment_status: "paid",
    lines: [["Ressemelage caoutchouc", 1], ["Bonbout talons aiguille", 1]]
  },
  {
    customer: customers[4],
    status: "in_progress",
    priority: "high",
    days_ago: 2,
    due_in: 2,
    payment_method: "card",
    payment_status: "unpaid",
    lines: [["Changement zip", 1]]
  },
  {
    customer: customers[5],
    status: "pending",
    priority: "medium",
    days_ago: 0,
    due_in: 5,
    payment_method: "cash",
    payment_status: "unpaid",
    lines: [["Recollage semelle", 1], ["Changement de lacets", 1]]
  },
  {
    customer: customers[6],
    status: "completed",
    priority: "medium",
    days_ago: 8,
    due_in: -2,
    payment_method: "card",
    payment_status: "paid",
    lines: [["Talon complet chaussures plates", 1]]
  },
  {
    customer: customers[7],
    status: "pending",
    priority: "low",
    days_ago: 1,
    due_in: 6,
    payment_method: "check",
    payment_status: "unpaid",
    lines: [["Entretien cuir nettoyage & cirage", 1]]
  }
]

orders_data.each do |data|
  created_at = Time.current - data[:days_ago].days
  due_date = Date.current + data[:due_in].days
  paid_at = data[:payment_status] == "paid" ? created_at + 1.hour : nil

  lines = data[:lines].map do |item_name, quantity|
    { item: items_by_name.fetch(item_name), quantity: quantity }
  end

  created_orders << create_order_with_lines!(
    establishment: establishment,
    customer: data[:customer],
    status: data[:status],
    priority: data[:priority],
    created_at: created_at,
    due_date: due_date,
    payment_method: data[:payment_method],
    payment_status: data[:payment_status],
    paid_at: paid_at,
    collected_at: nil,
    internal_notes: notes.sample,
    lines: lines
  )
end

puts "Creating 5 recent transactions..."

5.times do |index|
  created_at = Time.current.change(hour: 9 + index, min: [0, 15, 30, 45].sample)

  created_orders << create_order_with_lines!(
    establishment: establishment,
    customer: customers[index % customers.length],
    status: ["pending", "in_progress", "completed"].sample,
    priority: ["medium", "high"].sample,
    created_at: created_at,
    due_date: Date.current + rand(1..6).days,
    payment_method: ["card", "cash"].sample,
    payment_status: ["paid", "unpaid"].sample,
    paid_at: [true, false].sample ? created_at + 30.minutes : nil,
    collected_at: nil,
    internal_notes: notes.sample,
    lines: [{ item: items.sample, quantity: [1, 1, 2].sample }]
  )
end

puts "Creating communications..."

created_orders.select { |order| ["pending", "in_progress"].include?(order.status) }.first(4).each_with_index do |order, index|
  customer = order.customer

  Communication.create!(
    order: order,
    channel: index.even? ? "sms" : "email",
    status: index.even? ? "draft" : "sent",
    content: "Bonjour #{customer.firstname}, votre commande est bien prise en charge par l’Atelier Claude. Je vous préviens dès qu’elle est prête.",
    sent_at: index.even? ? nil : Time.current - rand(1..4).hours
  )
end

puts "Creating pickup-reminder test orders..."

business_days_ago = lambda do |n|
  date = Date.current
  remaining = n

  while remaining.positive?
    date -= 1
    remaining -= 1 if (1..5).include?(date.wday)
  end

  date.to_time.change(hour: 10)
end

reminder_item = items_by_name["Ressemelage sneakers"]

reminder_scenarios = [
  { customer: customers[0], waiting: 0, note: "TEST — commande prête aujourd’hui." },
  { customer: customers[1], waiting: 4, note: "TEST — rappel retrait J+3 ouvrés." },
  { customer: customers[2], waiting: 12, note: "TEST — rappel retrait J+10 ouvrés." }
]

reminder_orders = reminder_scenarios.map do |scenario|
  created_at = business_days_ago.call(scenario[:waiting] + 1)

  order = create_order_with_lines!(
    establishment: establishment,
    customer: scenario[:customer],
    status: "sent",
    priority: "medium",
    created_at: created_at,
    due_date: created_at.to_date,
    payment_method: "card",
    payment_status: "paid",
    paid_at: created_at,
    collected_at: nil,
    internal_notes: scenario[:note],
    lines: [{ item: reminder_item, quantity: 1 }]
  )

  ready_at = scenario[:waiting].zero? ? Time.current : business_days_ago.call(scenario[:waiting])
  order.update_columns(sms_reminder: true, ready_at: ready_at)

  order
end

puts "Creating due-date-alert test orders..."

[
  { customer: customers[3], status: "pending", offset: 1, note: "TEST — retrait imminent J+1." },
  { customer: customers[4], status: "in_progress", offset: 0, note: "TEST — retrait aujourd’hui." },
  { customer: customers[5], status: "in_progress", offset: -2, note: "TEST — retrait dépassé J-2." }
].each do |scenario|
  create_order_with_lines!(
    establishment: establishment,
    customer: scenario[:customer],
    status: scenario[:status],
    priority: "high",
    created_at: Time.current - 3.days,
    due_date: Date.current + scenario[:offset],
    payment_method: "card",
    payment_status: "unpaid",
    paid_at: nil,
    collected_at: nil,
    internal_notes: scenario[:note],
    lines: [{ item: reminder_item, quantity: 1 }]
  )
end

puts "Creating history-demo order..."

history_created_at = Time.zone.local(2026, 6, 4, 10, 0, 0)
history_ready_at = Time.zone.local(2026, 6, 5, 10, 0, 0)
history_reminder_at = Time.zone.local(2026, 6, 10, 10, 0, 0)

history_order = create_order_with_lines!(
  establishment: establishment,
  customer: customers[6],
  status: "sent",
  priority: "medium",
  created_at: history_created_at,
  due_date: history_created_at.to_date,
  payment_method: "card",
  payment_status: "paid",
  paid_at: history_created_at,
  collected_at: nil,
  internal_notes: "TEST — historique complet email + SMS.",
  lines: [{ item: reminder_item, quantity: 1 }]
)

history_order.update_columns(
  sms_reminder: true,
  ready_at: history_ready_at
)

history_order.communications.create!(
  channel: "sms",
  kind: "ready",
  status: "sent",
  content: history_order.sms_ready_message,
  sent_at: history_ready_at
)

history_order.communications.create!(
  channel: "sms",
  kind: "reminder_j3",
  status: "sent",
  content: history_order.pickup_reminder_message,
  sent_at: history_reminder_at
)

puts "Seeds finished!"
puts "#{User.count} user created"
puts "#{Establishment.count} establishment created"
puts "#{Customer.count} customers created"
puts "#{Item.count} items created"
puts "#{Order.count} orders created"
puts "#{OrderLine.count} order lines created"
puts "#{Communication.count} communications created"
puts "Compte test : demo@popwearpro.com / password"
