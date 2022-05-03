class DropQuestionsSubjectsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :questions_subjects
  end
end
