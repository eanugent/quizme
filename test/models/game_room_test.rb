require "test_helper"

class GameRoomTest < ActiveSupport::TestCase
  setup do
    @room = GameRoom.create!(
      room_key: "1234",
      game_type: "Bible Characters",
      score_to_win: "3",
      seconds_per_turn: 60,
      is_open: true,
      player_turn_order: []
    )
    @player1 = Player.create!(game_room: @room, name: "Alice", score: 0)
    @player2 = Player.create!(game_room: @room, name: "Bob", score: 0)
    @room.update!(host_player_id: @player1.id, my_turn_player_id: @player1.id)
  end

  test "add_player_to_turn_order does not duplicate players" do
    @room.add_player_to_turn_order(@player1.id)
    @room.add_player_to_turn_order(@player1.id)
    @room.add_player_to_turn_order(@player2.id)

    assert_equal [@player1.id, @player2.id], @room.player_turn_order
  end

  test "increment_my_turn_player_id advances through players" do
    @room.update!(player_turn_order: [@player1.id, @player2.id], my_turn_player_id: @player1.id)

    @room.increment_my_turn_player_id
    assert_equal @player2.id, @room.my_turn_player_id

    @room.increment_my_turn_player_id
    assert_equal @player1.id, @room.my_turn_player_id
  end

  test "increment_my_turn_player_id handles missing current player" do
    @room.update!(player_turn_order: [@player1.id, @player2.id], my_turn_player_id: nil)

    @room.increment_my_turn_player_id
    assert_equal @player1.id, @room.my_turn_player_id
  end

  test "increment_my_turn_player_id is safe with empty turn order" do
    @room.update!(player_turn_order: [], my_turn_player_id: @player1.id)

    assert_nothing_raised do
      @room.increment_my_turn_player_id
    end

    assert_equal @player1.id, @room.reload.my_turn_player_id
  end
end
