require "test_helper"

class GameChannelTest < ActionCable::Channel::TestCase
  setup do
    @room = GameRoom.create!(
      room_key: "5678",
      game_type: "Bible Characters",
      score_to_win: "3",
      seconds_per_turn: 60,
      is_open: true,
      player_turn_order: []
    )
    @host = Player.create!(game_room: @room, name: "Host", score: 0)
    @guest = Player.create!(game_room: @room, name: "Guest", score: 0)
    @room.update!(host_player_id: @host.id)
  end

  test "subscribes when player belongs to room" do
    subscribe room_key: @room.room_key, player_id: @host.id

    assert subscription.confirmed?
    assert @host.reload.is_connected
  end

  test "rejects subscription when player is not in room" do
    other_room = GameRoom.create!(
      room_key: "9999",
      game_type: "Bible Characters",
      score_to_win: "3",
      seconds_per_turn: 60,
      is_open: true
    )
    outsider = Player.create!(game_room: other_room, name: "Outsider", score: 0)

    subscribe room_key: @room.room_key, player_id: outsider.id

    assert subscription.rejected?
  end

  test "report_connected deduplicates turn order" do
    subscribe room_key: @room.room_key, player_id: @host.id

    perform :report_connected
    perform :report_connected

    assert_equal [@host.id], @room.reload.player_turn_order
  end

  test "process_expired_turn ignores actions when it is not the players turn" do
    @room.update!(
      player_turn_order: [@host.id, @guest.id],
      my_turn_player_id: @host.id
    )
    game = PickSubjectGame.create!(
      game_type: @room.game_type,
      game_room_id: @room.id,
      status: "in_progress"
    )

    subscribe room_key: @room.room_key, player_id: @guest.id

    perform :process_expired_turn

    assert_equal 0, game.reload.expired_turn_count
    assert_equal @host.id, @room.reload.my_turn_player_id
  end
end
