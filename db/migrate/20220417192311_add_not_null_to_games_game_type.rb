class AddNotNullToGamesGameType < ActiveRecord::Migration[6.1]
  def change
    change_column :games, :game_type, :string, null: false
  end
end
