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
  ["Mehdi", "Kacem", "mehdi.kacem@email.com", "07 26 37 48 59", "Client régulier pour ressemelage."],
  ["Julie", "Petit", "julie.petit@email.com", "07 90 12 34 56", "Cliente récente. Commandes simples."],
  ["Antoine", "Rousseau", "antoine.rousseau@email.com", "06 44 55 66 77", "Client occasionnel."],
  ["Sarah", "Dubois", "sarah.dubois@email.com", "07 41 22 33 44", "Aime être prévenue par SMS."],
  ["Vincent", "Aubert", "vincent.aubert@email.com", "07 65 54 43 32", "Dépôts fréquents le samedi."],
  ["Lina", "Fontaine", "lina.fontaine@email.com", "06 11 22 33 44", "Cliente récente."],
  ["Alexandre", "Noël", "alexandre.noel@email.com", "07 99 88 77 66", "Réparations chaussures haut de gamme."],
  ["Claire", "Bousquet", "claire.bousquet@email.com", "07 19 28 37 46", "Commandes souvent des travaux simples."],

  ["David", "Azure", "david.azure@email.com", "06 20 21 22 23", "Client démo. Référence IA Azure."],
  ["Charles", "Mistral", "charles.mistral@email.com", "06 24 25 26 27", "Client démo. Référence IA Mistral."],
  ["Gemma", "Gemini", "gemma.gemini@email.com", "06 28 29 30 31", "Cliente démo. Référence IA Gemini."],
  ["Pauline", "Laurent", "pauline.laurent@email.com", "06 14 25 36 47", "Préfère les finitions discrètes."],
  ["Jean", "Paquet", "jean.paquet@email.com", "07 33 44 55 66", "Client fidèle. Paiement souvent par carte."],
  ["Marie", "Colin", "marie.colin@email.com", "06 88 77 66 55", "Demande régulièrement du cirage premium."],
  ["Romain", "Masson", "romain.masson@email.com", "07 48 59 60 71", "Souvent pressé. Délais courts."],
  ["Amandine", "Perrot", "amandine.perrot@email.com", "06 73 84 95 16", "Articles cuir et petites réparations."],
  ["Chloé", "Vidal", "chloe.vidal@email.com", "06 97 86 75 64", "Préfère être contactée par email."],
  ["Bastien", "Delafontaine", "bastien.delafontaine@email.com", "06 21 45 78 12", "Dépose souvent des sneakers."],
  ["Mathieu", "Girard", "mathieu.girard@email.com", "06 78 11 23 45", "Souhaite des réparations solides avant l’esthétique."],
  ["Olivier", "Mercier", "olivier.mercier@email.com", "06 61 72 83 94", "Client professionnel. Délais importants."],
  ["Nadia", "Lefèvre", "nadia.lefevre@email.com", "06 45 18 92 30", "Cliente fidèle. Préfère être appelée en fin de journée."],
  ["Fatima", "Cherif", "fatima.cherif@email.com", "06 10 20 30 40", "Très attentive aux délais."],
  ["Lucas", "Garnier", "lucas.garnier@email.com", "07 34 56 78 90", "Réparations cuir. Demande souvent des délais rapides."]
]

customers = customers_data.each_with_index.map do |(firstname, lastname, email, phone, notes), index|
  created_at =
    if index < 15
      Time.zone.local(2026, 5, index + 1, 10, 0, 0)
    else
      Time.zone.local(2026, 6, index - 14, 10, 0, 0)
    end

  Customer.create!(
    establishment: establishment,
    firstname: firstname,
    lastname: lastname,
    email: email,
    phone: phone,
    notes: notes,
    created_at: created_at,
    updated_at: created_at
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
    created_at: Time.zone.local(2026, 6, 11, 9, 0, 0),
    due_date: Date.new(2026, 6, 14),
    payment_method: "card",
    payment_status: "unpaid",
    lines: [["Pose de patins x2", 1], ["Cirage & glaçage", 1]]
  },
  {
    customer: customers[1],
    status: "in_progress",
    priority: "urgent",
    created_at: Time.zone.local(2026, 6, 10, 10, 0, 0),
    due_date: Date.new(2026, 6, 12),
    payment_method: "cash",
    payment_status: "unpaid",
    lines: [["Ressemelage sneakers", 1]]
  },
  {
    customer: customers[2],
    status: "completed",
    priority: "medium",
    created_at: Time.zone.local(2026, 6, 8, 11, 0, 0),
    due_date: Date.new(2026, 6, 11),
    payment_method: "card",
    payment_status: "paid",
    lines: [["Rénovation complète cuir", 1]]
  },
  {
    customer: customers[3],
    status: "sent",
    priority: "medium",
    created_at: Time.zone.local(2026, 6, 6, 12, 0, 0),
    due_date: Date.new(2026, 6, 10),
    payment_method: "card",
    payment_status: "paid",
    lines: [["Ressemelage caoutchouc", 1], ["Bonbout talons aiguille", 1]]
  },
  {
    customer: customers[4],
    status: "in_progress",
    priority: "high",
    created_at: Time.zone.local(2026, 6, 9, 14, 0, 0),
    due_date: Date.new(2026, 6, 13),
    payment_method: "card",
    payment_status: "unpaid",
    lines: [["Changement zip", 1]]
  },
  {
    customer: customers[5],
    status: "pending",
    priority: "medium",
    created_at: Time.zone.local(2026, 6, 11, 15, 0, 0),
    due_date: Date.new(2026, 6, 16),
    payment_method: "cash",
    payment_status: "unpaid",
    lines: [["Recollage semelle", 1], ["Changement de lacets", 1]]
  },
  {
    customer: customers[6],
    status: "completed",
    priority: "medium",
    created_at: Time.zone.local(2026, 6, 3, 10, 30, 0),
    due_date: Date.new(2026, 6, 7),
    payment_method: "card",
    payment_status: "paid",
    lines: [["Talon complet chaussures plates", 1]]
  },
  {
    customer: customers[7],
    status: "pending",
    priority: "low",
    created_at: Time.zone.local(2026, 6, 10, 16, 0, 0),
    due_date: Date.new(2026, 6, 17),
    payment_method: "check",
    payment_status: "unpaid",
    lines: [["Entretien cuir nettoyage & cirage", 1]]
  }
]

orders_data.each do |data|
  paid_at = data[:payment_status] == "paid" ? data[:created_at] + 1.hour : nil

  lines = data[:lines].map do |item_name, quantity|
    { item: items_by_name.fetch(item_name), quantity: quantity }
  end

  created_orders << create_order_with_lines!(
    establishment: establishment,
    customer: data[:customer],
    status: data[:status],
    priority: data[:priority],
    created_at: data[:created_at],
    due_date: data[:due_date],
    payment_method: data[:payment_method],
    payment_status: data[:payment_status],
    paid_at: paid_at,
    collected_at: nil,
    internal_notes: notes.sample,
    lines: lines
  )
end

puts "Creating 5 recent transactions..."

recent_transactions_data = [
  [customers[8],  Time.zone.local(2026, 6, 11, 9, 30, 0)],
  [customers[9],  Time.zone.local(2026, 6, 11, 10, 30, 0)],
  [customers[10], Time.zone.local(2026, 6, 11, 11, 30, 0)],
  [customers[11], Time.zone.local(2026, 6, 11, 12, 15, 0)],
  [customers[12], Time.zone.local(2026, 6, 11, 13, 45, 0)]
]

recent_transactions_data.each_with_index do |(customer, created_at), index|
  payment_status = index.even? ? "paid" : "unpaid"

  created_orders << create_order_with_lines!(
    establishment: establishment,
    customer: customer,
    status: ["pending", "in_progress", "completed"][index % 3],
    priority: ["medium", "high"][index % 2],
    created_at: created_at,
    due_date: Date.new(2026, 6, 12 + index),
    payment_method: ["card", "cash"][index % 2],
    payment_status: payment_status,
    paid_at: payment_status == "paid" ? created_at + 30.minutes : nil,
    collected_at: nil,
    internal_notes: notes.sample,
    lines: [{ item: items[index % items.length], quantity: index == 4 ? 2 : 1 }]
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
    sent_at: index.even? ? nil : Time.zone.local(2026, 6, 11, 14, 0, 0) - index.hours
  )
end

puts "Creating pickup-reminder test orders..."

reminder_item = items_by_name["Ressemelage sneakers"]

reminder_scenarios = [
  {
    customer: customers[13],
    created_at: Time.zone.local(2026, 6, 10, 10, 0, 0),
    ready_at: Time.zone.local(2026, 6, 11, 10, 0, 0),
    note: "TEST — commande prête aujourd’hui."
  },
  {
    customer: customers[14],
    created_at: Time.zone.local(2026, 6, 2, 10, 0, 0),
    ready_at: Time.zone.local(2026, 6, 5, 10, 0, 0),
    note: "TEST — rappel retrait J+3 ouvrés."
  },
  {
    customer: customers[15],
    created_at: Time.zone.local(2026, 6, 1, 10, 0, 0),
    ready_at: Time.zone.local(2026, 6, 1, 12, 0, 0),
    note: "TEST — rappel retrait avancé, sans date avant juin."
  }
]

reminder_orders = reminder_scenarios.map do |scenario|
  order = create_order_with_lines!(
    establishment: establishment,
    customer: scenario[:customer],
    status: "sent",
    priority: "medium",
    created_at: scenario[:created_at],
    due_date: scenario[:created_at].to_date,
    payment_method: "card",
    payment_status: "paid",
    paid_at: scenario[:created_at],
    collected_at: nil,
    internal_notes: scenario[:note],
    lines: [{ item: reminder_item, quantity: 1 }]
  )

  order.update_columns(
    sms_reminder: true,
    ready_at: scenario[:ready_at]
  )

  order
end

puts "Creating due-date-alert test orders..."

[
  {
    customer: customers[16],
    status: "pending",
    created_at: Time.zone.local(2026, 6, 8, 10, 0, 0),
    due_date: Date.new(2026, 6, 12),
    note: "TEST — retrait imminent J+1."
  },
  {
    customer: customers[17],
    status: "in_progress",
    created_at: Time.zone.local(2026, 6, 8, 11, 0, 0),
    due_date: Date.new(2026, 6, 11),
    note: "TEST — retrait aujourd’hui."
  },
  {
    customer: customers[18],
    status: "in_progress",
    created_at: Time.zone.local(2026, 6, 8, 12, 0, 0),
    due_date: Date.new(2026, 6, 9),
    note: "TEST — retrait dépassé J-2."
  }
].each do |scenario|
  create_order_with_lines!(
    establishment: establishment,
    customer: scenario[:customer],
    status: scenario[:status],
    priority: "high",
    created_at: scenario[:created_at],
    due_date: scenario[:due_date],
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
  customer: customers[19],
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
