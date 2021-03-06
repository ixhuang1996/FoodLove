# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160809175706) do

  create_table "buyers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "distributors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "distributors_farms", id: false, force: :cascade do |t|
    t.integer "farm_id"
    t.integer "distributor_id"
  end

  add_index "distributors_farms", ["distributor_id"], name: "index_distributors_farms_on_distributor_id"
  add_index "distributors_farms", ["farm_id"], name: "index_distributors_farms_on_farm_id"

  create_table "farms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "file"
  end

  create_table "notifications", force: :cascade do |t|
    t.text     "notif"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "farm_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "buyer_id"
    t.string   "name"
    t.datetime "placed"
  end

  add_index "orders", ["buyer_id"], name: "index_orders_on_buyer_id"

  create_table "orders_users", id: false, force: :cascade do |t|
    t.integer "farm_id"
    t.integer "order_id"
    t.integer "distributor_id"
  end

  add_index "orders_users", ["distributor_id"], name: "index_distributors_orders_on_distributor_id"
  add_index "orders_users", ["farm_id"], name: "index_orders_users_on_farm_id"
  add_index "orders_users", ["order_id"], name: "index_orders_users_on_order_id"

  create_table "products", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "unit"
    t.decimal  "price",       precision: 5, scale: 2
    t.integer  "quantity"
    t.string   "category"
    t.boolean  "feature"
    t.text     "description"
    t.text     "notes"
    t.integer  "farm_id"
  end

  create_table "quantities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "quant"
    t.integer  "order_id"
    t.integer  "product_id"
  end

  add_index "quantities", ["order_id"], name: "index_quantities_on_order_id"
  add_index "quantities", ["product_id"], name: "index_quantities_on_product_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "type"
    t.text     "location"
    t.string   "remember_digest"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "users_users", force: :cascade do |t|
    t.integer "farm_id"
    t.integer "distributor_id"
    t.integer "buyer_id"
  end

  add_index "users_users", ["buyer_id"], name: "index_users_users_on_buyer_id"
  add_index "users_users", ["distributor_id"], name: "index_users_users_on_distributor_id"
  add_index "users_users", ["farm_id"], name: "index_users_users_on_farm_id"

end
