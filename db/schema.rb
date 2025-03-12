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

ActiveRecord::Schema[7.2].define(version: 2025_03_12_072328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lotteries", force: :cascade do |t|
    t.string "name"
    t.text "dict"
    t.integer "reality"
    t.boolean "default_check", default: false
    t.integer "origin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "random_set_id", null: false
    t.boolean "default_pickup", default: false
    t.integer "value", default: 0
    t.index ["random_set_id"], name: "index_lotteries_on_random_set_id"
  end

  create_table "random_sets", force: :cascade do |t|
    t.string "name"
    t.integer "parent"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "dict"
    t.string "edit_pass"
    t.string "session_digest"
    t.string "password_digest"
  end

  add_foreign_key "lotteries", "random_sets"
end
