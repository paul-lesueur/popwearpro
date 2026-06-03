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
  name: "Marie Dupont"
)

puts "Creating establishment..."

establishment = Establishment.create!(
  user: user,
  name: "Atelier Popwear",
  description: "Atelier de retouche, couture et réparation textile.",
  address: "12 rue des Artisans, 75011 Paris",
  category: "couture",
  payment_methods: "Carte bancaire, espèces, virement",
  opening_hours: "Lundi au samedi, 9h30 - 18h30",
  siret_siren: "12345678900012"
)

puts "Creating customers..."

customers_data = [
  {
    firstname: "Camille",
    lastname: "Martin",
    email: "camille.martin@email.com",
    phone: "06 12 34 56 78",
    notes: "Cliente régulière. Préfère être contactée par SMS."
  },
  {
    firstname: "Thomas",
    lastname: "Bernard",
    email: "thomas.bernard@email.com",
    phone: "06 98 76 54 32",
    notes: "Commande souvent des réparations urgentes."
  },
  {
    firstname: "Sophie",
    lastname: "Leroy",
    email: "sophie.leroy@email.com",
    phone: "07 22 44 66 88",
    notes: "Aime les finitions premium."
  },
  {
    firstname: "Nadia",
    lastname: "Lefèvre",
    email: "nadia.lefevre@email.com",
    phone: "06 45 18 92 30",
    notes: "Cliente fidèle. Préfère être appelée en fin de journée."
  },
  {
    firstname: "Karim",
    lastname: "Benali",
    email: "karim.benali@email.com",
    phone: "07 11 23 45 67",
    notes: "Dépose souvent plusieurs articles en même temps."
  },
  {
    firstname: "Inès",
    lastname: "Moreau",
    email: "ines.moreau@email.com",
    phone: "06 77 88 99 10",
    notes: "Préfère être contactée par email. Retouches robes et vestes."
  },
  {
    firstname: "Lucas",
    lastname: "Garnier",
    email: "lucas.garnier@email.com",
    phone: "07 34 56 78 90",
    notes: "Réparations cuir. Demande souvent des délais rapides."
  },
  {
    firstname: "Fatima",
    lastname: "Cherif",
    email: "fatima.cherif@email.com",
    phone: "06 10 20 30 40",
    notes: "Très attentive aux délais. Prévenir en cas de retard."
  },
  {
    firstname: "Antoine",
    lastname: "Rousseau",
    email: "antoine.rousseau@email.com",
    phone: "06 44 55 66 77",
    notes: "Client occasionnel. À relancer quand la commande est prête."
  },
  {
    firstname: "Julie",
    lastname: "Petit",
    email: "julie.petit@email.com",
    phone: "07 90 12 34 56",
    notes: "Cliente récente. Commandes simples, surtout ourlets et retouches."
  }
]

customers = customers_data.map do |customer_data|
  Customer.create!(
    establishment: establishment,
    firstname: customer_data[:firstname],
    lastname: customer_data[:lastname],
    email: customer_data[:email],
    phone: customer_data[:phone],
    notes: customer_data[:notes]
  )
end

customer_1 = customers[0]
customer_2 = customers[1]
customer_3 = customers[2]
customer_4 = customers[3]
customer_5 = customers[4]
customer_6 = customers[5]
customer_7 = customers[6]
customer_8 = customers[7]
customer_9 = customers[8]
customer_10 = customers[9]

puts "Creating catalog items..."

ourlet = Item.create!(
  establishment: establishment,
  name: "Ourlet pantalon",
  price_ht: 18.00,
  vat_rate: 20.00,
  repair_bonus: true,
  photo_url: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea",
  active: true
)

fermeture = Item.create!(
  establishment: establishment,
  name: "Réparation fermeture éclair",
  price_ht: 35.00,
  vat_rate: 20.00,
  repair_bonus: true,
  photo_url: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2",
  active: true
)

robe = Item.create!(
  establishment: establishment,
  name: "Retouche robe",
  price_ht: 55.00,
  vat_rate: 20.00,
  repair_bonus: false,
  photo_url: "https://images.unsplash.com/photo-1595777457583-95e059d581b8",
  active: true
)

veste = Item.create!(
  establishment: establishment,
  category: "service",
  name: "Ajustement veste",
  price_ht: 48.00,
  vat_rate: 20.00,
  repair_bonus: false,
  photo_url: "https://images.unsplash.com/photo-1594938298603-c8148c4dae35",
  active: true
)

sac_cuir = Item.create!(
  establishment: establishment,
  category: "service",
  name: "Réparation sac cuir",
  price_ht: 42.00,
  vat_rate: 20.00,
  repair_bonus: true,
  photo_url: "https://images.unsplash.com/photo-1590874103328-eac38a683ce7",
  active: true
)

lacets = Item.create!(
  establishment: establishment,
  category: "product",
  name: "Lacets premium",
  price_ht: 8.00,
  vat_rate: 20.00,
  repair_bonus: false,
  photo_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
  active: true
)

produit_cuir = Item.create!(
  establishment: establishment,
  category: "product",
  name: "Produit d'entretien cuir",
  price_ht: 14.00,
  vat_rate: 20.00,
  repair_bonus: false,
  photo_url: "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519",
  active: true
)

puts "Creating orders..."

def create_order_with_lines!(establishment:, customer:, status:, priority:, due_date:, payment_method:, payment_status:, paid_at:, collected_at:, internal_notes:, lines:)
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
    internal_notes: internal_notes
  )

  lines.each do |line|
    item = line[:item]

    OrderLine.create!(
      order: order,
      item: item,
      quantity: line[:quantity],
      unit_price_ht: item.price_ht,
      vat_rate: item.vat_rate
    )
  end

  order
end

order_1 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_1,
  status: "in_progress",
  priority: "high",
  due_date: Date.current + 2.days,
  payment_method: "card",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Robe à reprendre à la taille. Prévenir la cliente si retard.",
  lines: [
    { item: robe, quantity: 1 }
  ]
)

Communication.create!(
  order: order_1,
  channel: "sms",
  status: "draft",
  content: "Bonjour Camille, votre retouche est bien en cours. Je vous tiens informée dès qu'elle est prête.",
  sent_at: nil
)

order_2 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_2,
  status: "pending",
  priority: "urgent",
  due_date: Date.current + 1.day,
  payment_method: "cash",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Fermeture éclair à remplacer rapidement.",
  lines: [
    { item: fermeture, quantity: 1 }
  ]
)

Communication.create!(
  order: order_2,
  channel: "email",
  status: "sent",
  content: "Bonjour Thomas, votre réparation de fermeture éclair est prévue en priorité. Je reviens vers vous dès que c'est terminé.",
  sent_at: Time.current
)

order_3 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_3,
  status: "completed",
  priority: "medium",
  due_date: Date.current - 1.day,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current - 1.day,
  collected_at: nil,
  internal_notes: "Ourlets terminés. En attente de récupération.",
  lines: [
    { item: ourlet, quantity: 2 },
    { item: lacets, quantity: 1 }
  ]
)

order_4 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_1,
  status: "delivered",
  priority: "low",
  due_date: Date.current - 5.days,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current - 4.days,
  collected_at: Time.current - 3.days,
  internal_notes: "Commande livrée et payée.",
  lines: [
    { item: produit_cuir, quantity: 1 }
  ]
)

order_4 = Order.create!(
order_5 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_4,
  status: "in_progress",
  priority: "medium",
  due_date: Date.current + 4.days,
  payment_method: "card",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Ajustement veste. Cliente disponible en fin de journée.",
  lines: [
    { item: veste, quantity: 1 }
  ]
)

order_6 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_5,
  status: "pending",
  priority: "high",
  due_date: Date.current + 3.days,
  payment_method: "cash",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Lot de trois articles déposés. Commencer par la fermeture éclair.",
  lines: [
    { item: fermeture, quantity: 1 },
    { item: ourlet, quantity: 2 }
  ]
)

order_7 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_6,
  status: "completed",
  priority: "medium",
  due_date: Date.current,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current,
  collected_at: nil,
  internal_notes: "Retouche robe terminée. Prévenir par email.",
  lines: [
    { item: robe, quantity: 1 }
  ]
)

order_8 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_7,
  status: "in_progress",
  priority: "urgent",
  due_date: Date.current + 1.day,
  payment_method: "card",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Réparation cuir urgente. Client souhaite un appel dès que terminé.",
  lines: [
    { item: sac_cuir, quantity: 1 },
    { item: produit_cuir, quantity: 1 }
  ]
)

order_9 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_8,
  status: "pending",
  priority: "high",
  due_date: Date.current + 6.days,
  payment_method: "cash",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Cliente attentive aux délais. Prévenir si la date bouge.",
  lines: [
    { item: veste, quantity: 1 }
  ]
)

order_10 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_9,
  status: "delivered",
  priority: "low",
  due_date: Date.current - 10.days,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current - 9.days,
  collected_at: Time.current - 8.days,
  internal_notes: "Commande terminée sans problème.",
  lines: [
    { item: lacets, quantity: 2 },
    { item: produit_cuir, quantity: 1 }
  ]
)

OrderLine.create!(
  order: order_4,
  item: robe,
  quantity: 1,
  unit_price_ht: robe.price_ht,
  vat_rate: robe.vat_rate
order_11 = create_order_with_lines!(
  establishment: establishment,
  customer: customer_10,
  status: "in_progress",
  priority: "medium",
  due_date: Date.current + 7.days,
  payment_method: "card",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Première commande. Faire une finition soignée.",
  lines: [
    { item: ourlet, quantity: 1 },
    { item: fermeture, quantity: 1 }
  ]
)

Communication.create!(
  order: order_8,
  channel: "sms",
  status: "draft",
  content: "Bonjour Lucas, votre réparation cuir est en cours. Je vous appelle dès que la pièce est prête.",
  sent_at: nil
)

Communication.create!(
  order: order_9,
  channel: "email",
  status: "draft",
  content: "Bonjour Fatima, votre veste est bien prise en charge. Je vous préviens immédiatement en cas de changement de délai.",
  sent_at: nil
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
