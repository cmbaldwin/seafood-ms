# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_28_014911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.integer "category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.string "title"
    t.index ["article_id"], name: "index_comments_on_article_id"
  end

  create_table "expiration_cards", force: :cascade do |t|
    t.string "product_name"
    t.string "manufacturer_address"
    t.string "manufacturer"
    t.string "ingredient_source"
    t.string "consumption_restrictions"
    t.string "manufactuered_date"
    t.string "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "download"
    t.string "storage_recommendation"
    t.boolean "made_on"
    t.boolean "shomiorhi"
  end

  create_table "frozen_oysters", force: :cascade do |t|
    t.decimal "hyogo_raw"
    t.decimal "okayama_raw"
    t.text "frozen_l"
    t.text "frozen_ll"
    t.text "finished_packs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "manufacture_date"
    t.string "ampm"
    t.text "losses"
  end

  create_table "infomart_orders", force: :cascade do |t|
    t.bigint "order_id"
    t.string "status"
    t.string "destination"
    t.datetime "order_time"
    t.date "ship_date"
    t.date "arrival_date"
    t.text "items"
    t.string "address"
    t.text "csv_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "manifests", force: :cascade do |t|
    t.string "sales_date"
    t.text "infomart_orders"
    t.text "online_shop_orders"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "markets", force: :cascade do |t|
    t.string "namae"
    t.string "address"
    t.string "phone"
    t.string "repphone"
    t.string "fax"
    t.decimal "cost"
    t.text "history"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mjsnumber"
    t.string "zip"
    t.string "nick"
    t.decimal "one_time_cost"
    t.decimal "optional_cost"
    t.string "one_time_cost_description"
    t.string "optional_cost_description"
    t.decimal "block_cost"
    t.string "color"
    t.decimal "handling"
    t.boolean "brokerage"
  end

  create_table "materials", force: :cascade do |t|
    t.string "namae"
    t.string "zairyou"
    t.decimal "cost"
    t.text "history"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "divisor"
    t.boolean "per_product"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user"
    t.string "model"
    t.string "message"
    t.boolean "state"
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "document"
  end

  create_table "noshis", force: :cascade do |t|
    t.integer "ntype"
    t.string "omotegaki"
    t.string "namae"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "noshi_url"
    t.string "image"
    t.string "namae2"
    t.string "namae3"
    t.string "namae4"
    t.string "namae5"
  end

  create_table "online_orders", force: :cascade do |t|
    t.bigint "order_id"
    t.datetime "order_time"
    t.datetime "date_modified"
    t.string "status"
    t.date "ship_date"
    t.date "arrival_date"
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "oyster_invoices", force: :cascade do |t|
    t.string "start_date"
    t.string "end_date"
    t.string "aioi_all_pdf"
    t.string "aioi_seperated_pdf"
    t.string "sakoshi_all_pdf"
    t.string "sakoshi_seperated_pdf"
    t.boolean "completed"
    t.string "aioi_emails"
    t.string "sakoshi_emails"
    t.datetime "send_at", precision: 0
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "oyster_invoices_supplies", id: false, force: :cascade do |t|
    t.bigint "oyster_supply_id", null: false
    t.bigint "oyster_invoice_id", null: false
    t.index ["oyster_invoice_id", "oyster_supply_id"], name: "supply_invoice_index"
  end

  create_table "oyster_supplies", force: :cascade do |t|
    t.text "oysters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supply_date"
    t.datetime "oysters_last_update"
    t.text "totals"
  end

  create_table "product_and_market_joins", force: :cascade do |t|
    t.integer "product_id"
    t.integer "market_id"
  end

  create_table "product_and_material_joins", force: :cascade do |t|
    t.integer "product_id"
    t.integer "material_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "namae"
    t.decimal "grams"
    t.decimal "cost"
    t.decimal "count"
    t.decimal "multiplier"
    t.text "history"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_type"
    t.decimal "extra_expense"
    t.boolean "profitable"
    t.decimal "average_price"
    t.text "infomart_association"
    t.boolean "associated", default: false
  end

  create_table "profit_and_market_joins", force: :cascade do |t|
    t.integer "profit_id"
    t.integer "market_id"
  end

  create_table "profit_and_product_joins", force: :cascade do |t|
    t.integer "profit_id"
    t.integer "product_id"
  end

  create_table "profits", force: :cascade do |t|
    t.string "sales_date"
    t.text "figures"
    t.text "totals"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.text "debug_figures"
    t.boolean "split"
    t.boolean "ampm"
    t.text "subtotals"
    t.text "volumes"
  end

  create_table "r_manifests", force: :cascade do |t|
    t.text "orders_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "Rakuten_Order"
    t.string "sales_date"
    t.text "new_orders_hash"
  end

  create_table "restaurant_and_manifest_joins", force: :cascade do |t|
    t.integer "restaurant_id"
    t.integer "manifest_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "namae"
    t.string "company"
    t.string "link"
    t.string "address"
    t.string "arrival_time"
    t.text "products"
    t.text "stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "company_name"
    t.integer "supplier_number"
    t.string "address"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location"
    t.text "representatives", default: [], array: true
    t.string "home_address"
    t.integer "phone"
    t.index ["user_id"], name: "index_suppliers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.boolean "approved", default: false, null: false
    t.integer "role"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "username"
    t.text "data"
    t.index ["approved"], name: "index_users_on_approved"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "yahoo_orders", force: :cascade do |t|
    t.string "order_id"
    t.date "ship_date"
    t.text "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "articles"
end
