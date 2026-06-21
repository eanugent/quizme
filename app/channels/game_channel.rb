class GameChannel < ApplicationCable::Channel

  attr_reader :room, :player

  def subscribed
    @room = GameRoom.find_by_key(params[:room_key])

    return reject unless @room

    @player = Player.find_by(id: params[:player_id], game_room_id: room.id)

    return reject unless @player

    player.is_connected = true
    player.save

    stream_for room
  end

  def unsubscribed
    return unless player && room

    player.is_connected = false
    player.save
    room.process_player_disconnected(player.id)
  end

  def report_connected
    room.reload

    room.add_player_to_turn_order(player.id)

    data = {
      type: 'game_room_change'
    }.merge(room.room_state_for_json)

    GameChannel.broadcast_to(room, data)
  end

  def start_new_game
    return unless player.id == room.host_player_id

    room.reload
    room.pick_subject_games.where(status: 'in_progress').update_all(status: 'complete')

    PickSubjectGame.create(
        game_type: room.game_type,
        game_room_id: room.id
    )

    room.player_turn_order = room.player_turn_order.uniq.shuffle
    room.my_turn_player_id = room.player_turn_order.first
    room.save

    room.reload

    broadcast_room_change
  end

  def process_question(data)
    room.reload
    return unless players_turn?

    question = Question.find(data["question_id"])
    game = room.current_game
    return unless game

    answer_val = game.process_question(question.id)

    unless answer_val == 1
      room.increment_my_turn_player_id
    end

    response_data = {
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

    GameChannel.broadcast_to(room, response_data)
  end

  def process_guess(data)
    room.reload
    return unless players_turn?

    subject = Subject.find(data["subject_id"])
    game = room.current_game
    return unless game

    answer_val = game.process_guess(subject.id)

    if(answer_val == 1) 
      player.score += 1;
      player.save
    end

    unless game.status == 'complete'
      room.increment_my_turn_player_id
    end

    response_data = {
        type: 'guess_processed',
        guessed_subject_id: subject.id,
        name: subject.name,
        game_status: game.status,
        answer_val: answer_val,
        correct_subject_id: game.status == 'complete' ? game.subject_id : -1,
        my_turn_player_id: room.my_turn_player_id,
        my_turn_player_name: room.my_turn_player_name
    }

    GameChannel.broadcast_to(room, response_data)
  end

  def process_expired_turn()
    room.reload
    return unless players_turn?

    game = room.current_game
    return unless game

    game.process_expired_turn
    
    unless game.status == 'complete'
      room.increment_my_turn_player_id
    end

    response_data = {
      type: 'turn_expired',
      expired_turn_count: game.expired_turn_count,
      game_status: game.status,
      correct_subject_id: game.status == 'complete' ? game.subject_id : -1,
      my_turn_player_id: room.my_turn_player_id,
      my_turn_player_name: room.my_turn_player_name
    }
      
    GameChannel.broadcast_to(room, response_data)    
  end

  private

  def players_turn?
    room.my_turn_player_id == player.id
  end

  def broadcast_room_change
    data = {
        type: 'game_room_change'
    }.merge(room.room_state_for_json)

    GameChannel.broadcast_to(room, data)
  end
end
