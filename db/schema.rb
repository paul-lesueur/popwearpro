# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_03_140335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "communications", force: :cascade do |t|
    t.string "channel"
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.datetime "sent_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_communications_on_order_id"
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "establishment_id", null: false
    t.string "firstname"
    t.string "lastname"
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["establishment_id"], name: "index_customers_on_establishment_id"
  end

  create_table "establishments", force: :cascade do |t|
    t.string "address"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "opening_hours"
    t.jsonb "opening_schedule", default: {}, null: false
    t.string "payment_methods"
    t.string "siret_siren"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_establishments_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.bigint "establishment_id", null: false
    t.string "name"
    t.string "photo_url"
    t.decimal "price_ht"
    t.boolean "repair_bonus"
    t.datetime "updated_at", null: false
    t.decimal "vat_rate"
    t.index ["establishment_id"], name: "index_items_on_establishment_id"
  end

  create_table "order_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "item_id", null: false
    t.bigint "order_id", null: false
    t.integer "quantity"
    t.decimal "unit_price_ht"
    t.datetime "updated_at", null: false
    t.decimal "vat_rate"
    t.index ["item_id"], name: "index_order_lines_on_item_id"
    t.index ["order_id"], name: "index_order_lines_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "collected_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.date "due_date"
    t.bigint "establishment_id", null: false
    t.text "internal_notes"
    t.datetime "paid_at"
    t.string "payment_method"
    t.string "payment_status"
    t.string "priority"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["establishment_id"], name: "index_orders_on_establishment_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "communications", "orders"
  add_foreign_key "customers", "establishments"
  add_foreign_key "establishments", "users"
  add_foreign_key "items", "establishments"
  add_foreign_key "order_lines", "items"
  add_foreign_key "order_lines", "orders"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "establishments"
end
