class ChangeGameKeyToRoomKey < ActiveRecord::Migration[6.1]
  def change
    rename_column :game_room, :game_key, :room_key
  end
end
