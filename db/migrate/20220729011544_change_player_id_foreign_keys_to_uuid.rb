class ChangePlayerIdForeignKeysToUuid < ActiveRecord::Migration[6.1]
  def change
    remove_column :game_rooms, :host_player_id
    remove_column :game_rooms, :my_turn_player_id
    remove_column :game_rooms, :player_turn_order

    add_column :game_rooms, :host_player_id, :uuid
    add_column :game_rooms, :my_turn_player_id, :uuid
    add_column :game_rooms, :player_turn_order, :uuid, default: [], array: true
  end
end
