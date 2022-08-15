require 'csv'

def clear_game_type(type)
  q_ids = Question.where(game_type: type).pluck(:id)

  Answer.where(question_id: q_ids).delete_all
  Question.where(id: q_ids).delete_all
  Subject.where(game_type: type).delete_all
end

csv_text = File.read(Rails.root.join('lib', 'seeds', 'questions.csv'))
csv = CSV.parse(csv_text, :headers => true)
subjects = csv_text.split("\r\n")[0].split(',').select{|h| h.start_with?("_")}

cleared_types = []

csv.each do |row|
  next if row["Id"].blank? || row["Question"].blank?

  unless cleared_types.include?(row["Game Type"])
    clear_game_type(row["Game Type"])
    cleared_types << row["Game Type"]
  end

  q = Question.new
  q.id = row["Id"]
  q.game_type = row["Game Type"]
  q.question = row["Question"]
  q.use_in_kahoot = row["Kahoot?"] == "1"
  q.save
#p "Question: #{q.question}"
  subjects.each do |s|
    next if row[s].blank?
#p "  Subject: #{s}"
    name = s[1..].strip
    subject = Subject.find_or_create_by(name: name, game_type: row["Game Type"])
    a = Answer.new(question: q, subject: subject, answer_val: row[s])
    a.save
    #p '      #{subject}'
  end
end