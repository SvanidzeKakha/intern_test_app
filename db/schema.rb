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

ActiveRecord::Schema[8.1].define(version: 2026_02_12_201043) do
  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "industry"
    t.string "name"
    t.string "size"
    t.datetime "updated_at", null: false
  end

  create_table "company_names", force: :cascade do |t|
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_company_names_on_company_id_and_name", unique: true
  end

  create_table "product_names", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "product_id"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "user_product_interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["product_id"], name: "index_user_product_interests_on_product_id"
    t.index ["user_id"], name: "index_user_product_interests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "fname"
    t.string "lname"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
  end

  add_foreign_key "user_product_interests", "products"
  add_foreign_key "user_product_interests", "users"
  add_foreign_key "users", "companies"
end
