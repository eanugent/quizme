class ReplaceStatusColumnWithIsOpenColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :game_room, :status
    add_column :game_room, :is_open, :boolean, default: false
  end
end
