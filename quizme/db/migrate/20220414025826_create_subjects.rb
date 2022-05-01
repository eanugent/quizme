class CreateSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :subjects do |t|
      t.string :game_type
      t.string :name

      t.timestamps
    end
  end
end