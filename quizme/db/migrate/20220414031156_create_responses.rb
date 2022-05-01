class CreateResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :responses do |t|
      t.string :game_type
      t.string :response
      t.integer :threshold

      t.timestamps
    end
  end
end
