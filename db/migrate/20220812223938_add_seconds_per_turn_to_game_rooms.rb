class AddSecondsPerTurnToGameRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rooms, :seconds_per_turn, :int, default: 60
  end
end
