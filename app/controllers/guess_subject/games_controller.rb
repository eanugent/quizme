module GuessSubject
    class GamesController < ActionController::Base

        skip_before_action :verify_authenticity_token

        RECENT_GAME_MINUTES_AGO = 10

        def show
            render json: { data: game, status: :ok, message: 'Success' }
        end

        def create
            @game = PickSubjectGame.new(game_type: game_type_param)
            @game.save

            render json:
            { 
                data:
                {
                    game_id: @game.id,
                    next_question_options: next_question_options,
                    game_status: @game.status
                },
                status: :ok
            }
        end

        def index
            render json: { data: recent_games, status: :ok }
        end

        def process_question
            answer_val = game.process_question(question_id_param)

            render json:
            {
                data:
                {
                    game_status: game.status,
                    answer_val: answer_val,
                    next_question_options: next_question_options
                },
                status: :ok,
                message: nil
            }
        end

        private

        def id_param
            params.require(:id)
        end

        def game_type_param
            params.require(:game_type)
        end

        def question_id_param
            params.require(:question_id).to_i
        end

        def answer_val_param
            params.require(:answer_val).to_i
        end

        def game
            @game ||= GuessSubjectGame.find(id_param)
        end

        def next_question
            @next_question ||= Question.find(game.next_question_id)
        end

        def recent_games
            GuessSubjectGame.where('updated_at > ?', RECENT_GAME_MINUTES_AGO.minutes.ago)
        end
    end
end