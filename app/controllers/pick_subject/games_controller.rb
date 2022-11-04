module PickSubject
    class GamesController < ActionController::Base

        skip_before_action :verify_authenticity_token

        RECENT_GAME_MINUTES_AGO = 10

        def show
            render json: { data: game, status: :ok, message: 'Success' }
        end

        def create
            unless id_param
                @game = PickSubjectGame.create(game_type: game_type_param)
            end
            
            render json:
            { 
                data:
                {
                    game_id: game.id,
                    next_question_options: next_question_options,
                    game_status: game.status
                },
                status: :ok
            }
        end

        def index
            render json: { data: recent_games, status: :ok }
        end

        def game_types
            render json: {
                data: Subject.distinct.pluck(:game_type),
                status: :ok
            }
        end

        private

        def id_param
            params[:id]
        end

        def game_type_param
            params.require(:game_type)
        end

        def game
            @game ||= PickSubjectGame.find(id_param)
        end

        def next_question_options
            @next_question_options ||= game.next_question_options
        end

        def recent_games
            PickSubjectGame.where('updated_at > ?', RECENT_GAME_MINUTES_AGO.minutes.ago)
        end
    end
end