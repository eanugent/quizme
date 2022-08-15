class AddExpiredTurnCountToPickSubjectGame < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :expired_turn_count, :int, default: 0
  end
end
