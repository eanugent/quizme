class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :game_type
      t.string :question
      t.boolean :use_in_kahoot

      t.timestamps
    end
  end
end
