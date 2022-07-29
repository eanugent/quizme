class CreateMultiPlayerGames < ActiveRecord::Migration[6.1]
  def change
    create_table :multi_player_games do |t|
      t.string :url_key
      t.string :game_type
      t.integer :score_to_win
      t.integer :host_player_id
      t.integer :my_turn_player_id
      t.integer :player_turn_order, default: [], array: true      

      t.timestamps
    end
  end
end