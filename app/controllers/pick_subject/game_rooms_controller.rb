module PickSubject
    class GameRoomsController < ActionController::Base

        skip_before_action :verify_authenticity_token

        def show
            render json: { data: room, status: :ok, message: 'Success' }
        end

        def create
            room_key = [*0..9, *'A'..'Z'].shuffle[0..3].join

            room = GameRoom.create(
                room_key: room_key,
                game_type: game_type_param,
                score_to_win: score_to_win_param,
                is_open: true
            )
            
            player = Player.create(
                game_room_id: room.id,
                name: player_name_param,
                avatar_id: 0,
                score: 0,
                is_connected: false
            )

            room.host_player_id = player.id
            room.save

            render json:
            { 
                data:
                {
                    game_room_id: room.id,
                    room_key: room.room_key,
                    player_id: player.id
                },
                status: :ok
            }
        end

        def start_new_game
            game = PickSubjectGame.create(game_type: game_type_param)
            
            data =
            { 
                game_id: game.id,
                next_question_options: next_question_options,
                game_status: game.status
            }
        end

        private

        def game_type_param
            params.require(:game_type)
        end

        def score_to_win_param
            params.require(:score_to_win)
        end

        def player_name_param
            params.require(:player_name)
        end
    end
end