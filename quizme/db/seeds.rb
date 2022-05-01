require 'csv'

Question.delete_all
Subject.delete_all
Answer.delete_all
Response.delete_all

csv_text = File.read(Rails.root.join('lib', 'seeds', 'questions.csv'))
csv = CSV.parse(csv_text, :headers => true)
subjects = csv_text.split("\r\n")[0].split(',').select{|h| h.start_with?("_")}

csv.each do |row|
  next if row["Id"].blank? || row["Question"].blank?
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
    name = s[1..]
    subject = Subject.find_or_create_by(name: name, game_type: row["Game Type"])
    a = Answer.new(question: q, subject: subject, answer_val: row[s])
    a.save
    #p '      #{subject}'
  end
end