class ChangeMultiPlayerGamesToGameRoom < ActiveRecord::Migration[6.1]
  def change
    rename_table :multi_player_games, :game_room
  end
end
