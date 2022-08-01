class RemoveIntegerIdColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :game_rooms, :integer_id
    remove_column :players, :integer_id
  end
end
