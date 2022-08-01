module PickSubject
    class GameRoomsController < ActionController::Base

        skip_before_action :verify_authenticity_token

        def show
            render json:
            { 
                data: room.room_state_for_json,
                status: :ok
            }
        end

        def create
            room_key = [*0..9, *'A'..'Z'].shuffle[0..3].join

            new_room = GameRoom.create(
                room_key: room_key,
                game_type: game_type_param,
                score_to_win: score_to_win_param,
                is_open: true
            )

            player = Player.create(
                game_room_id: new_room.id,
                name: player_name_param,
                avatar_id: 0,
                score: 0,
                is_connected: false
            )

            new_room.host_player_id = player.id
            new_room.save

            render json:
            { 
                data:
                {
                    game_room_id: new_room.id,
                    room_key: new_room.room_key,
                    player_id: player.id
                },
                status: :ok
            }
        end

        def add_player
            room = GameRoom.find_by_key(room_key_param)
            player = Player.create(
                game_room_id: room.id,
                name: player_name_param,
                avatar_id: 0,
                score: 0
              )
            
            render json:
            { 
                data:
                {
                    player_id: player.id
                },
                status: :ok
            }
        end

        # def start_new_game
        #     game = PickSubjectGame.create(
        #         game_type: room.game_type,
        #         game_room_id: id_param
        #     )
            
        #     broadcast_room_change
        # end

        # def player_connected
        #     @room_id = player.game_room_id
        #     broadcast_room_change
        # end

        private

        def id_param
            params.require(:id)
        end

        def room_key_param
            params.require(:room_key)
        end

        def game_type_param
            params.require(:game_type)
        end

        def score_to_win_param
            params.require(:score_to_win)
        end

        def player_name_param
            params.require(:player_name)
        end

        def player
            Player.find(params.require(:player_id))
        end

        def room
            @room ||= GameRoom.find(@room_id || id_param)
        end
        
        def broadcast_room_change
            data = {
                type: 'game_room_change'
            }.merge(room.room_state_for_json)

            GameChannel.broadcast_to(room, data)
            render json: { status: :ok }
        end
    end
end