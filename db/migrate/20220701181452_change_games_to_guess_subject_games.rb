class ChangeGamesToGuessSubjectGames < ActiveRecord::Migration[6.1]
  def change
    rename_table :games, :guess_subject_games
  end
end
