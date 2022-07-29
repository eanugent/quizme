class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.integer :multi_player_game_id
      t.string :name
      t.integer :avatar_id
      t.integer :score
      t.boolean :is_connected

      t.timestamps
    end
  end
end