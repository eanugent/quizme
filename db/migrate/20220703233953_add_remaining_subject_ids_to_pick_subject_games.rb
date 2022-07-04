class AddRemainingSubjectIdsToPickSubjectGames < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :remaining_subject_ids, :int, default: [], array: true
  end
end
