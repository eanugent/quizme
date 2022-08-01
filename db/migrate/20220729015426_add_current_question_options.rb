class AddCurrentQuestionOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :pick_subject_games, :current_question_ids, :integer, array: true, default: []
  end
end
