class ChangeMultiPlayerForeignKeys < ActiveRecord::Migration[6.1]
  def change
    rename_column :players, :multi_player_game_id, :game_room_id
    rename_column :pick_subject_games, :multi_player_game_id, :game_room_id
  end
end
