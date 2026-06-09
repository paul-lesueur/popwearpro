# This file should ensure the existence of records required to run the application in every environment.
# Warning: this seed resets demo data. Use locally for development/demo.

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
  description: "Atelier de cordonnerie artisanale parisien spécialisé dans la réparation, l’entretien et la rénovation de chaussures et articles en cuir.",
  address: "12 rue des Artisans, 75011 Paris",
  category: "Cordonnier",
  payment_methods: "Carte bancaire, espèces, chèque",
  opening_hours: "Lundi au samedi, 9h30 - 18h30",
  siret_siren: "12345678900012"
)

puts "Creating customers..."

customers_data = [
  ["Camille", "Martin", "camille.martin@email.com", "06 12 34 56 78", "Cliente régulière. Préfère être contactée par SMS."],
  ["Thomas", "Bernard", "thomas.bernard@email.com", "06 98 76 54 32", "Commande souvent des réparations urgentes."],
  ["Sophie", "Leroy", "sophie.leroy@email.com", "07 22 44 66 88", "Aime les finitions premium."],
  ["Nadia", "Lefèvre", "nadia.lefevre@email.com", "06 45 18 92 30", "Cliente fidèle. Préfère être appelée en fin de journée."],
  ["Karim", "Benali", "karim.benali@email.com", "07 11 23 45 67", "Dépose souvent plusieurs articles en même temps."],
  ["Inès", "Moreau", "ines.moreau@email.com", "06 77 88 99 10", "Préfère être contactée par email."],
  ["Lucas", "Garnier", "lucas.garnier@email.com", "07 34 56 78 90", "Réparations cuir. Demande souvent des délais rapides."],
  ["Fatima", "Cherif", "fatima.cherif@email.com", "06 10 20 30 40", "Très attentive aux délais. Prévenir en cas de retard."],
  ["Antoine", "Rousseau", "antoine.rousseau@email.com", "06 44 55 66 77", "Client occasionnel. À relancer quand la commande est prête."],
  ["Julie", "Petit", "julie.petit@email.com", "07 90 12 34 56", "Cliente récente. Commandes simples."],
  ["Bastien", "Delafontaine", "bastien.delafontaine@email.com", "06 21 45 78 12", "Dépose souvent des sneakers."],
  ["Thomas", "Dumas", "thomas.dumas@email.com", "06 52 18 74 90", "Préfère payer en espèces."],
  ["Élise", "Robert", "elise.robert@email.com", "07 15 82 44 31", "Cliente régulière pour entretien cuir."],
  ["Mathieu", "Girard", "mathieu.girard@email.com", "06 78 11 23 45", "Souhaite des réparations solides avant l’esthétique."],
  ["Sarah", "Dubois", "sarah.dubois@email.com", "07 41 22 33 44", "Aime être prévenue par SMS."],
  ["Olivier", "Mercier", "olivier.mercier@email.com", "06 61 72 83 94", "Client professionnel. Délais importants."],
  ["Claire", "Bousquet", "claire.bousquet@email.com", "07 19 28 37 46", "Commandes souvent des travaux simples."],
  ["Jérôme", "Racine", "jerome.racine@email.com", "06 90 81 72 63", "Dépose souvent des chaussures de ville."],
  ["Pauline", "Laurent", "pauline.laurent@email.com", "06 14 25 36 47", "Préfère les finitions discrètes."],
  ["Jean", "Paquet", "jean.paquet@email.com", "07 33 44 55 66", "Client fidèle. Paiement souvent par carte."],
  ["Marie", "Colin", "marie.colin@email.com", "06 88 77 66 55", "Demande régulièrement du cirage premium."],
  ["Hugo", "Renard", "hugo.renard@email.com", "07 12 89 45 67", "Sneakers et zip principalement."],
  ["Laura", "Simon", "laura.simon@email.com", "06 32 14 58 79", "Prévenir dès que la commande est prête."],
  ["Romain", "Masson", "romain.masson@email.com", "07 48 59 60 71", "Souvent pressé. Délais courts."],
  ["Amandine", "Perrot", "amandine.perrot@email.com", "06 73 84 95 16", "Articles cuir et petites réparations."],
  ["Mehdi", "Kacem", "mehdi.kacem@email.com", "07 26 37 48 59", "Client régulier pour ressemelage."],
  ["Chloé", "Vidal", "chloe.vidal@email.com", "06 97 86 75 64", "Préfère être contactée par email."],
  ["Vincent", "Aubert", "vincent.aubert@email.com", "07 65 54 43 32", "Dépôts fréquents le samedi."],
  ["Lina", "Fontaine", "lina.fontaine@email.com", "06 11 22 33 44", "Cliente récente."],
  ["Alexandre", "Noël", "alexandre.noel@email.com", "07 99 88 77 66", "Réparations chaussures haut de gamme."]
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
  { name: "Entretien cuir (nettoyage & cirage)", price_ht: 25, bonus: false, icon: "cirage" },
  { name: "Cirage & glaçage", price_ht: 29, bonus: false, icon: "cirage" },
  { name: "Rénovation complète cuir", price_ht: 55, bonus: false, icon: "finition" },
  { name: "Changement de lacets", price_ht: 5, bonus: false, icon: "reparer" },
  { name: "Pose de patins (x2)", price_ht: 26, bonus: true, icon: "patins-fers" },
  { name: "Pose de fers (x2)", price_ht: 21, bonus: false, icon: "patins-fers" },
  { name: "Mise en forme – coup de pied", price_ht: 29, bonus: false, icon: "elargir" },
  { name: "Ressemelage collé caoutchouc (semelle complète)", price_ht: 83, bonus: true, icon: "ressemelage" },
  { name: "Ressemelage sneakers", price_ht: 70, bonus: true, icon: "ressemelage" },
  { name: "Ressemelage cousu rainette (semelle complète)", price_ht: 130, bonus: true, icon: "ressemelage" },
  { name: "Ressemelage Birkenstock", price_ht: 54, bonus: true, icon: "ressemelage" },
  { name: "Recollage semelle", price_ht: 30, bonus: true, icon: "ressemelage" },
  { name: "Bonbout – talons aiguille", price_ht: 15, bonus: true, icon: "talon-bonbout" },
  { name: "Talon complet (chaussures plates)", price_ht: 65, bonus: false, icon: "talon-bonbout" },
  { name: "Glissoirs (changement)", price_ht: 35, bonus: true, icon: "patins-fers" },
  { name: "Redresse avant / arrière", price_ht: 17, bonus: true, icon: "reparer" },
  { name: "Trou – rustine intérieure", price_ht: 20, bonus: true, icon: "dechirure" },
  { name: "Couture décousue", price_ht: 20, bonus: true, icon: "reparer" },
  { name: "Zip – changement (x1)", price_ht: 45, bonus: true, icon: "zip" },
  { name: "Zip de bottes – changement (x1)", price_ht: 55, bonus: true, icon: "zip" }
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

puts "Creating orders over several months..."

def create_order_with_lines!(
  establishment:,
  customer:,
  status:,
  priority:,
  created_at:,
  due_date:,
  payment_method:,
  payment_status:,
  paid_at:,
  collected_at:,
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

srand(42)

payment_methods = ["card", "cash", "check"]
priorities = ["low", "medium", "high", "urgent"]

notes = [
  "Prévenir le client dès que la commande est prête.",
  "Client pressé. Faire attention au délai.",
  "Vérifier la finition avant remise.",
  "Demande une finition propre et discrète.",
  "Commande déposée avec plusieurs articles.",
  "Travail simple, à faire dans la semaine.",
  "Réparation visible, expliquer le résultat au client.",
  "Client fidèle, soigner la communication."
]

# Répartition volontairement réaliste :
# - Beaucoup de commandes sur le mois courant
# - Quelques commandes sur les mois précédents
# - Un pic le jour actuel pour que le dashboard ait du contexte
months_offsets = [5, 4, 3, 2, 1, 0]
orders_per_month = {
  5 => 16,
  4 => 18,
  3 => 20,
  2 => 24,
  1 => 28,
  0 => 34
}

created_orders = []

months_offsets.each do |offset|
  month_date = Date.current - offset.months
  month_start = month_date.beginning_of_month
  month_end = offset.zero? ? Date.current : month_date.end_of_month

  orders_per_month[offset].times do
    order_date = rand(month_start..month_end)
    created_at = order_date.to_time.change(hour: rand(9..17), min: [0, 15, 30, 45].sample)

    customer = customers.sample
    payment_method = payment_methods.sample

    if order_date < Date.current - 7.days
      status = ["delivered", "completed"].sample
      payment_status = "paid"
      paid_at = created_at + rand(1..4).days
      collected_at = status == "delivered" ? paid_at + rand(1..3).days : nil
    elsif order_date < Date.current
      status = ["completed", "in_progress", "delivered"].sample
      payment_status = status == "delivered" ? "paid" : ["paid", "unpaid"].sample
      paid_at = payment_status == "paid" ? created_at + rand(1..3).days : nil
      collected_at = status == "delivered" ? created_at + rand(2..5).days : nil
    else
      status = ["pending", "in_progress"].sample
      payment_status = "unpaid"
      paid_at = nil
      collected_at = nil
    end

    lines_count = [1, 1, 1, 2, 2, 3].sample

    selected_items = items.sample(lines_count).map do |item|
      {
        item: item,
        quantity: [1, 1, 1, 2].sample
      }
    end

    order = create_order_with_lines!(
      establishment: establishment,
      customer: customer,
      status: status,
      priority: priorities.sample,
      created_at: created_at,
      due_date: order_date + rand(2..12).days,
      payment_method: payment_method,
      payment_status: payment_status,
      paid_at: paid_at,
      collected_at: collected_at,
      internal_notes: notes.sample,
      lines: selected_items
    )

    created_orders << order
  end
end

# Ajout d’un vrai pic de commandes aujourd’hui pour la page Transactions et le CA du jour.
today_items_pool = [
  items_by_name["Entretien cuir (nettoyage & cirage)"],
  items_by_name["Pose de patins (x2)"],
  items_by_name["Ressemelage sneakers"],
  items_by_name["Recollage semelle"],
  items_by_name["Zip – changement (x1)"],
  items_by_name["Bonbout – talons aiguille"],
  items_by_name["Couture décousue"]
]

13.times do |index|
  created_at = Time.current.change(hour: 9 + (index / 2), min: [0, 15, 30, 45].sample)

  line_item = today_items_pool.sample
  second_item = today_items_pool.sample

  lines = [{ item: line_item, quantity: [1, 1, 2].sample }]
  lines << { item: second_item, quantity: 1 } if index % 4 == 0

  order = create_order_with_lines!(
    establishment: establishment,
    customer: customers[index % customers.length],
    status: ["pending", "in_progress", "completed"].sample,
    priority: ["medium", "high", "urgent"].sample,
    created_at: created_at,
    due_date: Date.current + rand(1..8).days,
    payment_method: ["card", "cash"].sample,
    payment_status: ["paid", "unpaid"].sample,
    paid_at: [true, false].sample ? created_at + rand(10..90).minutes : nil,
    collected_at: nil,
    internal_notes: notes.sample,
    lines: lines
  )

  created_orders << order
end

puts "Creating communications..."

active_orders = created_orders.select { |order| ["pending", "in_progress"].include?(order.status) }.sample(8)

active_orders.each_with_index do |order, index|
  customer = order.customer
  first_name = customer.firstname.presence || "Bonjour"

  Communication.create!(
    order: order,
    channel: index.even? ? "sms" : "email",
    status: index.even? ? "draft" : "sent",
    content: "Bonjour #{first_name}, votre commande est bien prise en charge par l’Atelier Claude. Je vous préviens dès qu’elle est prête.",
    sent_at: index.even? ? nil : Time.current - rand(1..4).hours
  )
end

puts "Creating pickup-reminder test orders..."

# Renvoie un horodatage situé `n` jours ouvrés (lundi→vendredi) avant aujourd'hui.
business_days_ago = lambda do |n|
  date = Date.current
  remaining = n
  while remaining.positive?
    date -= 1
    remaining -= 1 if (1..5).include?(date.wday)
  end
  date.to_time.change(hour: 10)
end

reminder_item = items_by_name["Ressemelage sneakers"] || items_by_name.values.first

# Trois commandes « en attente de retrait » pour tester les rappels SMS.
# On crée d'abord la commande (le callback pose ready_at = maintenant), puis on
# force ready_at dans le passé via update_columns (sans repasser par les callbacks).
reminder_scenarios = [
  { customer: customers[0], waiting: 0,  note: "TEST — commande prête (J+0), à retirer." },
  { customer: customers[1], waiting: 4,  note: "TEST — retard de retrait (J+3 ouvrés)." },
  { customer: customers[2], waiting: 12, note: "TEST — retard de retrait (J+10 ouvrés)." }
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

reminder_orders.each do |order|
  puts "  -> CMD-#{order.id} (#{order.customer.display_name}) : " \
       "attente #{order.business_days_waiting} j ouvrés, palier #{order.pickup_reminder_level.inspect}"
end

puts "Creating due-date-alert test orders..."

# Commandes pas encore prêtes dont la date de retrait est imminente ou dépassée.
due_date_scenarios = [
  { customer: customers[3], status: "pending",     offset: 1,  note: "TEST — retrait imminent (J+1)." },
  { customer: customers[4], status: "in_progress", offset: 0,  note: "TEST — retrait aujourd'hui." },
  { customer: customers[5], status: "in_progress", offset: -2, note: "TEST — retrait dépassé (J-2)." }
]

due_date_orders = due_date_scenarios.map do |scenario|
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

due_date_orders.each do |order|
  puts "  -> CMD-#{order.id} (#{order.customer.display_name}) : " \
       "#{order.status}, retrait dans #{order.days_until_due} j, urgent #{order.urgent?}"
end

puts "Seeds finished!"
puts "#{User.count} user created"
puts "#{Establishment.count} establishment created"
puts "#{Customer.count} customers created"
puts "#{Item.count} items created"
puts "#{Order.count} orders created"
puts "#{OrderLine.count} order lines created"
puts "#{Communication.count} communications created"
puts "Compte test : demo@popwearpro.com / password"
