require "test_helper"

class GameRoomTest < ActiveSupport::TestCase
  # Build a room with the given per-player scores and a number of completed games.
  def build_room(scores:, score_to_win:, total_games:, completed_games:)
    room = GameRoom.create!(
      room_key: "T#{rand(1000)}",
      game_type: "Bible Characters",
      total_games: total_games,
      score_to_win: score_to_win,
      is_open: true
    )

    players = scores.map.with_index do |score, i|
      Player.create!(game_room_id: room.id, name: "P#{i}", avatar_id: 0, score: score)
    end

    completed_games.times do
      # subject_id present skips the before_create subject-sampling logic.
      PickSubjectGame.create!(
        game_type: "Bible Characters",
        subject_id: 1,
        status: "complete",
        game_room_id: room.id
      )
    end

    [room.reload, players]
  end

  test "majority clinch ends the series immediately" do
    room, players = build_room(scores: [2, 0], score_to_win: 2, total_games: 3, completed_games: 2)

    room.evaluate_series!

    assert_equal "complete", room.series_status
    assert_equal players.first.id, room.series_winner_player_id
  end

  test "exhausting the games with a single leader ends the series" do
    room, players = build_room(scores: [1, 0], score_to_win: 2, total_games: 3, completed_games: 3)

    room.evaluate_series!

    assert_equal "complete", room.series_status
    assert_equal players.first.id, room.series_winner_player_id
  end

  test "a tie after the games are exhausted keeps the series open for sudden death" do
    room, _players = build_room(scores: [1, 1], score_to_win: 2, total_games: 2, completed_games: 2)

    room.evaluate_series!

    assert_equal "in_progress", room.series_status
    assert_nil room.series_winner_player_id
  end

  test "series stays open while games remain and no majority" do
    room, _players = build_room(scores: [1, 0], score_to_win: 3, total_games: 5, completed_games: 1)

    room.evaluate_series!

    assert_equal "in_progress", room.series_status
  end
end
