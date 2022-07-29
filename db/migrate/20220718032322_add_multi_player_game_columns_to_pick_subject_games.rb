class AddMultiPlayerGameColumnsToPickSubjectGames < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :multi_player_game_id, :int
  end
end
