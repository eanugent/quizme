class GameChannel < ApplicationCable::Channel
  def subscribed
    @room = GameRoom.where(is_open: true, room_key: params[:room_key]).first
    return unless @room

    @player =
      if params[:player_id]
        Player.find(params[:player_id])
      else
        Player.new(
          game_room_id: @room.id,
          name: params[:name],
          avatar_id: params[:avatar_id] || 0,
          score: 0
        )
      end

    @player.is_connected = true
    @player.save

    msg_json =
    {
      type: "new_subscriber",
      data: {
        name: @player.name,
        avatar_id: @player.avatar_id
      }
    }

    GameChannel.broadcast_to(@room, msg_json)

    stream_for @room
  end

  def unsubscribed
    if @player
      @player.is_connected = false
      @player.save
    end    

    if @room
      @room.process_player_disconnected(@player.id)
    end
  end
end
