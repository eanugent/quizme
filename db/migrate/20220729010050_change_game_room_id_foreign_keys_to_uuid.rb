class ChangeGameRoomIdForeignKeysToUuid < ActiveRecord::Migration[6.1]
  def change
    remove_column :players, :game_room_id
    remove_column :pick_subject_games, :game_room_id

    add_column :players, :game_room_id, :uuid
    add_column :pick_subject_games, :game_room_id, :uuid
  end
end
