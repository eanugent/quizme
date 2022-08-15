class PickSubjectGame < ApplicationRecord
    belongs_to :subject, optional: true
    belongs_to :game_room, optional: true

    MAX_QUESTIONS = 10

    before_create do |game|
        if self.subject_id.nil?
            self.subject_ids = Subject.where(game_type: game_type).pluck(:id).sample(20)
            self.subject_id = self.subject_ids.sample
            self.remaining_subject_ids = self.subject_ids
            self.update_current_question_ids
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
                puts "#{game.remaining_subject_ids.count} left"
                game.print_remaining_subjects
                puts "\n\n"
                game.print_question_options
                puts "\n\n"

                input = gets.chomp

                break if input == "q"

                answer_val = game.process_question(input.to_i)
                answer_str = {
                    1 => "Yes",
                    2 => "No",
                    3 => "Not sure"
                }[answer_val]

                puts answer_str + "\n\n"

            rescue => exception
                puts "Error occurred: #{exception.message}"
                break
            end            
        end

        if(input == "q")
            puts "Did you guess #{game.subject.name}?"
        end
    end

    def subjects
        self.subject_ids.map do |id|
            Subject.find(id)
        end
    end

    def process_question(question_id)
        return -1 if self.asked_question_ids.include?(question_id)        
        self.asked_question_ids << question_id

        answer_val = self.subject.answers.where(question_id: question_id).first&.answer_val

        if [1,2].include?(answer_val)
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

        update_current_question_ids

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

    def process_expired_turn
        self.expired_turn_count += 1
        check_question_guess_count
        save
    end

    def check_question_guess_count
        if self.guessed_subject_ids.count +
           self.asked_question_ids.count +
           self.expired_turn_count >= MAX_QUESTIONS
            self.status = 'complete'
        end
    end

    def current_questions
        opts = {1 => "Yes", 2 => "No", 3 => "Not Sure"}
        self.current_question_ids.map do |question_id|
            Question.find(question_id)
            # q = Question.find(question_id)
            # q.question += " #{opts[q.answers.where(subject_id: subject_id).first.answer_val]}"
            # q
        end
    end

    def update_current_question_ids
        self.current_question_ids =
            if self.remaining_question_ids.count < 3
                self.remaining_question_ids.shuffle
            else
                # yes_ans, no_ans =
                #     subject.answers.select{|a| remaining_question_ids.include?(a.question_id) && [1,2].include?(a.answer_val)}.
                #         partition {|a| a.answer_val == 1}

                no_ans =
                    subject.answers.select{|a| a.answer_val == 2 && remaining_question_ids.include?(a.question_id) && [1,2].include?(a.answer_val)}

                ids = [
                    #yes_ans.sample&.question_id,
                    next_yes_question_id,
                    no_ans.sample&.question_id
                ].compact

                while ids.count < 3
                    id_to_try = remaining_question_ids.sample
                    unless ids.include?(id_to_try)
                        ids << id_to_try
                    end
                end

                ids.shuffle

                # scores = next_question_scores
                # threshhold_size = next_question_scores_threshhold_size(scores.count)

                # best_cutoff_index = threshhold_size - 1
                # worst_cutoff_index = scores.count - threshhold_size

                # best_question_index = rand(0..best_cutoff_index)
                # random_question_index = rand(best_cutoff_index+1..worst_cutoff_index-1) 
                # worst_question_index = rand(worst_cutoff_index..scores.count-1)
                
                # [
                #     scores[best_question_index][0],
                #     scores[random_question_index][0],
                #     scores[worst_question_index][0]
                # ].shuffle
            end
    end
    
    def next_yes_question_id
        Answer.where(question_id: remaining_yes_question_ids, subject_id: remaining_subject_ids).
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
            sort_by{ |k,v| v }.first&.first
    end

    def next_question_scores
        # The best next question is the question with the lowest value of
        # ABS(yes_answer_subjects - no_answer_subjects) + unknown_answer_subjects
        # This returns all options sorted in ascending order

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

    def next_question_scores_threshhold_size(score_count)
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

    def remaining_yes_question_ids
        remaining_question_ids.intersection(yes_question_ids)
    end

    def yes_question_ids
        @yes_question_ids ||= subject.answers.where(answer_val: 1).pluck(:question_id)
    end

    def print_remaining_subjects
        self.remaining_subject_ids.map do |id|
            Subject.find(id).name
        end.sort.each do |name|
            puts name
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
        end.sort.join(delimitter)
    end
end