class CreateAnswerTable < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.column "question_id", :integer, :null => false
      t.column "subject_id", :integer, :null => false
      t.column "answer_val", :integer, :null => false
    end
  end
end
