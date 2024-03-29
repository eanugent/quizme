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

ActiveRecord::Schema.define(version: 2022_08_14_200219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "subject_id", null: false
    t.integer "answer_val", null: false
  end

  create_table "game_rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "room_key"
    t.string "game_type"
    t.integer "score_to_win"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_open", default: false
    t.uuid "host_player_id"
    t.uuid "my_turn_player_id"
    t.uuid "player_turn_order", default: [], array: true
    t.integer "seconds_per_turn", default: 60
  end

  create_table "guess_subject_games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "game_type", null: false
    t.integer "remaining_subject_ids", default: [], array: true
    t.integer "asked_question_ids", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "answer_vals", default: [], array: true
    t.string "status", default: "in_progress"
  end

  create_table "pick_subject_games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "game_type", null: false
    t.integer "subject_id"
    t.integer "asked_question_ids", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "in_progress"
    t.integer "remaining_subject_ids", default: [], array: true
    t.integer "guessed_subject_ids", default: [], array: true
    t.uuid "game_room_id"
    t.integer "current_question_ids", default: [], array: true
    t.integer "subject_ids", default: [], array: true
    t.integer "expired_turn_count", default: 0
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "avatar_id"
    t.integer "score"
    t.boolean "is_connected"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "game_room_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "game_type"
    t.string "question"
    t.boolean "use_in_kahoot"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "responses", force: :cascade do |t|
    t.string "game_type"
    t.string "response"
    t.integer "threshold"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "game_type"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
