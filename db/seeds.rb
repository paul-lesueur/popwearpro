# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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

customer_1 = Customer.create!(
  establishment: establishment,
  firstname: "Camille",
  lastname: "Martin",
  email: "camille.martin@email.com",
  phone: "06 12 34 56 78",
  notes: "Cliente régulière. Préfère être contactée par SMS."
)

customer_2 = Customer.create!(
  establishment: establishment,
  firstname: "Thomas",
  lastname: "Bernard",
  email: "thomas.bernard@email.com",
  phone: "06 98 76 54 32",
  notes: "Commande souvent des réparations urgentes."
)

customer_3 = Customer.create!(
  establishment: establishment,
  firstname: "Sophie",
  lastname: "Leroy",
  email: "sophie.leroy@email.com",
  phone: "07 22 44 66 88",
  notes: "Aime les finitions premium."
)

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

puts "Creating orders..."

order_1 = Order.create!(
  establishment: establishment,
  customer: customer_1,
  status: "in_progress",
  priority: "high",
  due_date: Date.today + 2.days,
  payment_method: "card",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Robe à reprendre à la taille. Prévenir la cliente si retard."
)

OrderLine.create!(
  order: order_1,
  item: robe,
  quantity: 1,
  unit_price_ht: robe.price_ht,
  vat_rate: robe.vat_rate
)

Communication.create!(
  order: order_1,
  channel: "sms",
  status: "draft",
  content: "Bonjour Camille, votre retouche est bien en cours. Je vous tiens informée dès qu'elle est prête.",
  sent_at: nil
)

order_2 = Order.create!(
  establishment: establishment,
  customer: customer_2,
  status: "pending",
  priority: "urgent",
  due_date: Date.today + 1.day,
  payment_method: "cash",
  payment_status: "unpaid",
  paid_at: nil,
  collected_at: nil,
  internal_notes: "Fermeture éclair à remplacer rapidement."
)

OrderLine.create!(
  order: order_2,
  item: fermeture,
  quantity: 1,
  unit_price_ht: fermeture.price_ht,
  vat_rate: fermeture.vat_rate
)

Communication.create!(
  order: order_2,
  channel: "email",
  status: "sent",
  content: "Bonjour Thomas, votre réparation de fermeture éclair est prévue en priorité. Je reviens vers vous dès que c'est terminé.",
  sent_at: Time.current
)

order_3 = Order.create!(
  establishment: establishment,
  customer: customer_3,
  status: "completed",
  priority: "medium",
  due_date: Date.today - 1.day,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current - 1.day,
  collected_at: nil,
  internal_notes: "Ourlets terminés. En attente de récupération."
)

OrderLine.create!(
  order: order_3,
  item: ourlet,
  quantity: 2,
  unit_price_ht: ourlet.price_ht,
  vat_rate: ourlet.vat_rate
)

order_4 = Order.create!(
  establishment: establishment,
  customer: customer_1,
  status: "delivered",
  priority: "low",
  due_date: Date.today - 5.days,
  payment_method: "card",
  payment_status: "paid",
  paid_at: Time.current - 4.days,
  collected_at: Time.current - 3.days,
  internal_notes: "Commande livrée et payée."
)

OrderLine.create!(
  order: order_4,
  item: robe,
  quantity: 1,
  unit_price_ht: robe.price_ht,
  vat_rate: robe.vat_rate
)

puts "Seeds finished!"
puts "#{User.count} user created"
puts "#{Establishment.count} establishment created"
puts "#{Customer.count} customers created"
puts "#{Item.count} items created"
puts "#{Order.count} orders created"
puts "#{OrderLine.count} order lines created"
puts "#{Communication.count} communications created"
