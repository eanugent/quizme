class RemoveIntegerIdFromGames < ActiveRecord::Migration[6.1]
  def change
    remove_column :games, :integer_id
  end
end
