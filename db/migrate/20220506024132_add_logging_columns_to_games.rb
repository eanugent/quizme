class AddLoggingColumnsToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :answer_vals, :int, default: [], array: true
    add_column :games, :status, :string, default: "in_progress"
  end
end
