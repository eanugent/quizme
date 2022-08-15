class AddGameSubjectIds < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :subject_ids, :int, default: [], array: true    
  end
end
