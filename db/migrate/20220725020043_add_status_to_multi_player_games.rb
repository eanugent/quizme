class AddStatusToMultiPlayerGames < ActiveRecord::Migration[6.1]
  def change
    add_column :multi_player_games, :status, :string
  end
end
