class CreatePickSubjectGames < ActiveRecord::Migration[6.1]
  def change
    create_table :pick_subject_games, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "game_type", null: false
      t.integer "subject_id"
      t.integer "asked_question_ids", default: [], array: true
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "status", default: "in_progress"
    end
  end
end
