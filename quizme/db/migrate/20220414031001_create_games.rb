class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :game_type
      t.integer :remaining_subject_ids, array: true, default: []
      t.integer :asked_question_ids, array: true, default: []

      t.timestamps
    end
  end
end
