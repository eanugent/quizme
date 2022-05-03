module GuessSubject
    class GamesController < ActionController::Base

        skip_before_action :verify_authenticity_token

        RECENT_GAME_MINUTES_AGO = 10

        def show
            render json: { data: game, status: :ok, message: 'Success' }
        end

        def create
            @game = Game.new(game_type: game_type_param)
            @game.save

            render json:
            { 
                data:
                {
                    game_id: @game.id,
                    next_question: next_question,
                    game_status: 'in_progress'
                },
                status: :ok
            }
        end

        def index
            render json: { data: recent_games, status: :ok }
        end

        def characters
            render json:
            { 
                data: Subject.where(game_type: game_type_param).to_a.sort_by{|s| s.name},
                status: :ok
            }
        end

        def process_answer
            names_before_processing = game.remaining_subject_names.join(", ")
            game.process_answer(question_id_param.to_i, answer_val_param.to_i)

            if next_question.nil? || game.remaining_subject_ids.count == 0
                render json:
                {
                    data: { game_status: "complete" },
                    status: :ok,
                    message:
                        "Ugh, this is embarrassing ... I couldn't decide between these characters: #{names_before_processing}"
                }
            elsif game.remaining_subject_ids.count == 1
                render json:
                {
                    data: { game_status: "complete" },
                    status: :ok,
                    message: "Your person is #{game.remaining_subject_names[0]}!"
                }
            elsif game.remaining_subject_ids.count > 1
                render json:
                {
                    data:
                    {
                        game_status: "in_progress",
                        next_question: next_question
                    },
                    status: :ok,
                    message: nil
                }
            end
        end

        private

        def id_param
            params.require(:id)
        end

        def game_type_param
            params.require(:game_type)
        end

        def question_id_param
            params.require(:question_id)
        end

        def answer_val_param
            params.require(:answer_val)
        end

        def game
            @game ||= Game.find(id_param)
        end

        def next_question
            @next_question ||= Question.find(@game.next_question_id)
        end

        def recent_games
            Game.where('updated_at > ?', RECENT_GAME_MINUTES_AGO.minutes.ago)
        end
    end
end