class CreateJoinTableQuestionSubject < ActiveRecord::Migration[6.1]
  def change
    create_join_table :questions, :subjects do |t|
      t.integer :answer_value
      t.index [:question_id, :subject_id]
    end
  end
end
