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

ActiveRecord::Schema[7.2].define(version: 2025_07_22_103033) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "default_locations", force: :cascade do |t|
    t.string "name"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "itineraries", force: :cascade do |t|
    t.bigint "user_id"
    t.text "title", default: "タイトル未定", null: false
    t.text "subtitle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_itineraries_on_user_id"
  end

  create_table "itinerary_blocks", force: :cascade do |t|
    t.bigint "place_id", null: false
    t.datetime "starttime"
    t.text "description"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "itinerary_id", null: false
    t.index ["itinerary_id"], name: "index_itinerary_blocks_on_itinerary_id"
    t.index ["place_id"], name: "index_itinerary_blocks_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "google_place_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "lat"
    t.float "lng"
    t.index ["google_place_id"], name: "index_places_on_google_place_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "itineraries", "users"
  add_foreign_key "itinerary_blocks", "itineraries"
  add_foreign_key "itinerary_blocks", "places"
end
