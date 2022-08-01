class GameChannel < ApplicationCable::Channel

  attr_reader :room, :player

  def subscribed
    @room = GameRoom.find_by_key(params[:room_key])
    
    return unless @room

    @player = Player.find(params[:player_id])

    player.is_connected = true
    player.save

    msg_json =
    {
      type: "new_subscriber",
      data: {
        name: player.name,
        avatar_id: player.avatar_id
      }
    }

    stream_for room
  end

  def unsubscribed
    if player
      player.is_connected = false
      player.save
    end    

    if room
      room.process_player_disconnected(player.id)
    end
  end

  def report_connected
    room.reload

    room.player_turn_order.push(player.id)
    room.save

    data = {
      type: 'game_room_change'
    }.merge(room.room_state_for_json)

    GameChannel.broadcast_to(room, data)
  end

  def start_new_game
    return unless player.id == room.host_player_id

    game = PickSubjectGame.create(
        game_type: room.game_type,
        game_room_id: room.id
    )

    room.my_turn_player_id = room.player_turn_order[0]
    room.save

    room.reload

    broadcast_room_change
  end

  def process_question(data)
    room.reload

    question = Question.find(data["question_id"])
    game = room.current_game
    answer_val = game.process_question(question.id)

    room.increment_my_turn_player_id

    response_json = {
        type: 'question_processed',
        game_status: game.status,
        answer_val: answer_val,
        next_question_options: game.current_questions,
        correct_subject_id: game.status == 'complete' ? game.subject_id : -1,
        question: question.question,
        question_id: question.id,
        my_turn_player_id: room.my_turn_player_id,
        my_turn_player_name: room.my_turn_player_name
    }

    GameChannel.broadcast_to(room, response_json)
  end

  def process_guess(data)
    room.reload

    subject = Subject.find(data["subject_id"])
    game = room.current_game
    answer_val = game.process_guess(subject.id)

    room.increment_my_turn_player_id

    response_json = {
        type: 'guess_processed',
        guessed_subject_id: subject.id,
        name: subject.name,
        game_status: game.status,
        answer_val: answer_val,
        correct_subject_id: game.status == 'complete' ? game.subject_id : -1,
        my_turn_player_id: room.my_turn_player_id,
        my_turn_player_name: room.my_turn_player_name
    }

    GameChannel.broadcast_to(room, response_json)
  end

  private

  def broadcast_room_change
    data = {
        type: 'game_room_change'
    }.merge(room.room_state_for_json)

    GameChannel.broadcast_to(room, data)
  end
end
