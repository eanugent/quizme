class ChangeGameRoomToGameRooms < ActiveRecord::Migration[6.1]
  def change
    rename_table :game_room, :game_rooms
  end
end
