class Game < ApplicationRecord

    before_create do |game|
        if self.remaining_subject_ids.empty?
            self.remaining_subject_ids = Subject.where(game_type: game_type).pluck(:id)
        end
    end

    def self.run(game_type = "Bible Characters")
        old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
        game = Game.new(game_type: game_type)
        game.save
        input = ""
        #puts "Answer"
        while(!input.downcase.start_with?("q"))
            begin
                q = Question.find(game.next_question_id)
                puts "#{q.question}?"

                input = gets.chomp

                answer_val = {
                    "y" => 1,
                    "n" => 2,
                    "u" => 3
                }

                game.process_answer(q.id, answer_val[input.first])
                #game.print_remaining_subjects

                if game.remaining_subject_ids.count == 1
                    puts "Your person is #{Subject.find(game.remaining_subject_ids[0]).name}!"
                    break
                
                elsif game.remaining_subject_ids.count == 0
                    puts "You got me. Couldn't figure it out. Sorry :("
                    break
                end
            rescue => exception
                puts "Error occurred: #{exception.message}"
                break
            end            
        end

        if(input == "q")
            puts "Sorry to see you go"
        end
    end

    def process_answer(question_id, answer_val)
        return -1 if self.asked_question_ids.include?(question_id)
        self.asked_question_ids << question_id
        self.answer_vals << answer_val

        unless answer_val == 3
            wrong_answer_val = answer_val == 1 ? 2 : 1
            ids_to_remove =
                Answer.
                  where(question_id: question_id, answer_val: wrong_answer_val).
                  pluck(:subject_id).
                  intersection(self.remaining_subject_ids)

            remaining_count = self.remaining_subject_ids.count - ids_to_remove.count

            if remaining_count <= 1 # Found the subject or failed
                self.status = "complete"
            end

            unless remaining_count == 0
                self.remaining_subject_ids = self.remaining_subject_ids.excluding(ids_to_remove)                
            end                
        end

        save
        return 1        
    end

    def next_question_id
        # Next question is the question with the lowest value of
        # ABS(yes_answer_subjects - no_answer_subjects) + unknown_answer_subjects
        potential_next =
            Answer.where(question_id: remaining_question_ids, subject_id: remaining_subject_ids).
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
                end.to_a.to_h{|x| [x[0], ( (x[1][1] || 0) - (x[1][2] || 0) ).abs + (x[1][3] || 0)] }
                # sort_by{ |k,v| v }.
                # take(5)

        lowest_score = potential_next.min_by{|k,v| v}[1]
        potential_next.select{|k,v| v == lowest_score}.keys.sample
        #potential_next[rand(0..potential_next.count-1)][0]
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

    def remaining_subject_names(delimitter = ", ")
        self.remaining_subject_ids.map do |id|
            Subject.find(id).name
        end.join(delimitter)
    end    
end



    
    