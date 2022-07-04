class AddGuessedSubjectIdsToPickSubjectGames < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :guessed_subject_ids, :int, default: [], array: true
  end
end
