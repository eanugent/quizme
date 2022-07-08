class PickSubjectGame < ApplicationRecord
    belongs_to :subject, optional: true

    MAX_QUESTIONS = 10

    before_create do |game|
        if self.subject_id.nil?
            self.subject_id = Subject.pluck(:id).sample
        end

        if self.remaining_subject_ids.empty?
            self.remaining_subject_ids = Subject.where(game_type: game_type).pluck(:id)
        end
    end

    def self.run(game_type = "Bible Characters")
        old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
        game = PickSubjectGame.new(game_type: game_type)
        game.save
        input = ""

        while(!input.downcase.start_with?("q"))
            begin
                game.print_question_options

                input = gets.chomp

                break if input == "q"

                answer_val = game.process_question(input.to_i)
                answer_str = {
                    1 => "Yes",
                    2 => "No",
                    3 => "Not sure"
                }[answer_val]

                puts answer_str + "\n"
                #game.print_remaining_subjects

                # if game.remaining_subject_ids.count == 1
                #     puts "Your person is #{Subject.find(game.remaining_subject_ids[0]).name}!"
                #     break
                
                # elsif game.remaining_subject_ids.count == 0
                #     puts "You got me. Couldn't figure it out. Sorry :("
                #     break
                # end
            rescue => exception
                puts "Error occurred: #{exception.message}"
                break
            end            
        end

        if(input == "q")
            puts "Did you guess #{game.subject.name}?"
        end
    end

    def process_question(question_id)
        return -1 if self.asked_question_ids.include?(question_id)
        self.asked_question_ids << question_id

        answer_val = self.subject.answers.where(question_id: question_id).first&.answer_val

        unless answer_val == 3
            wrong_answer_val = answer_val == 1 ? 2 : 1
            ids_to_remove =
                Answer.
                  where(question_id: question_id, answer_val: wrong_answer_val).
                  pluck(:subject_id).
                  intersection(self.remaining_subject_ids)

            remaining_count = self.remaining_subject_ids.count - ids_to_remove.count

            unless remaining_count == 0
                self.remaining_subject_ids = self.remaining_subject_ids.excluding(ids_to_remove)                
            end                
        end

        check_question_guess_count

        save
        @next_question_scores = nil
        @next_question_options = nil
        answer_val
    end

    def process_guess(guessed_subject_id)
        unless self.guessed_subject_ids.include?(guessed_subject_id)
            self.guessed_subject_ids << guessed_subject_id
        end

        if guessed_subject_id == self.subject_id
            self.status = "complete"
            save
            1
        else
            check_question_guess_count
            save
            2
        end
    end

    def check_question_guess_count
        if self.guessed_subject_ids.count + self.asked_question_ids.count >= 10
            self.status = 'complete'
        end
    end

    def next_question_scores
        # The best next question is the question with the lowest value of
        # ABS(yes_answer_subjects - no_answer_subjects) + unknown_answer_subjects
        # This returns all options sorted in ascending order

        @next_question_scores ||=
            Answer.where(question_id: remaining_question_ids, subject_id: self.remaining_subject_ids).
                group(:question_id, :answer_val).
                count.
                group_by{|k,v| k[0]}.
                each_with_object({}) do |(k,v), h|
                    h[k] = v.flatten.values_at(1,2,4,5,7,8).map{|x| x || 0}
                end.each_with_object({}) do |(k,v), h|
                    h[k] = {}
                    index1 = v[0]
                    index2 = v[2]
                    index3 = v[4]

                    if index2 == 0
                        index2 = (index1 % 3) + 1
                        if index3 == 0
                            index3 = (index2 % 3) + 1
                        end
                    elsif index3 == 0
                        index3 = [1,2,3].excluding([index1, index2])[0]
                    end

                    h[k][index1] = v[1]
                    h[k][index2] = v[3]
                    h[k][index3] = v[5]
                end.to_a.to_h{|x| [x[0], ( (x[1][1] || 0) - (x[1][2] || 0) ).abs + (x[1][3] || 0)] }.
                sort_by{ |k,v| v }
    end

    def next_question_options
        @next_question_options ||=
            if self.remaining_question_ids.count < 3
                self.remaining_question_ids.shuffle
            else
                questions =
                    Answer.where(
                        question_id: remaining_question_ids,
                        subject_id: subject_id,
                        answer_val: [1,2]
                    ).pluck(
                        :question_id,
                        :answer_val
                    ).partition do |ans|
                        ans[1] == 1
                    end
                
                question_ids = []
                loop do
                    question_ids << questions[0].sample
                    question_ids << questions[1].sample
                    question_ids << questions[rand(0..1)].sample

                    question_ids = question_ids.uniq.compact
                    break if question_ids.count >= 3
                end

                question_ids.take(3).shuffle
            end.then do |ids|
                puts ids
                Question.where(id: ids.pluck(0)).map do |q|
                    q.question += " #{ids.find{|x| x[0] == q.id}[1]}"
                    q
                end
            end
    end

    def next_question_scores_threshhold_size
        score_count = next_question_scores.count
        size = 6
        while score_count.to_f / size <= 2
            size -= 1
            break if size == 2
        end
        size
    end

    def questions_query
        Question.where(game_type: game_type)
    end

    def remaining_question_ids
        questions_query.where.not(id: self.asked_question_ids).pluck(:id)
    end

    def print_remaining_subjects
        self.remaining_subject_ids.each do |id|
            puts Subject.find(id).name
        end
    end

    def print_question_options
        self.next_question_options.each do |question|
            puts "#{question.id} #{question.question}?"
        end
    end

    def remaining_subject_names(delimitter = ", ")
        self.remaining_subject_ids.map do |id|
            Subject.find(id).name
        end.join(delimitter)
    end
end