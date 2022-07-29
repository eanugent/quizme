class RenameUrlKey < ActiveRecord::Migration[6.1]
  def change
    rename_column :multi_player_games, :url_key, :game_key
  end
end
