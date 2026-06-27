class AddSeriesToGameRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rooms, :total_games, :integer, default: 1
    add_column :game_rooms, :projector_enabled, :boolean, default: false
    add_column :game_rooms, :series_status, :string, default: "in_progress"
    add_column :game_rooms, :series_winner_player_id, :uuid
  end
end
