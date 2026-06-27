class GameRoom < ApplicationRecord
    has_many :players
    has_many :pick_subject_games    

    def self.find_by_key(key)
        return self.where('is_open = ? AND lower(room_key) = ?', true, key.downcase).first
    end

    def room_state_for_json
        {
            host_player_id: host_player_id,
            host_player_name: host_player_name,
            seconds_per_turn: seconds_per_turn,
            my_turn_player_id: my_turn_player_id,
            my_turn_player_name: my_turn_player_name,
            players: players,
            game_id: current_game&.id,
            game_status: current_game&.status,
            current_questions: current_game&.current_questions,
            subjects: current_game&.subjects&.sort_by {|s| s.name },
            expired_turn_count: current_game&.expired_turn_count
        }.merge(series_state_for_json)
    end

    def series_state_for_json
        {
            total_games: total_games,
            score_to_win: score_to_win,
            projector_enabled: projector_enabled,
            games_completed: games_completed,
            series_status: series_status,
            series_winner_player_id: series_winner_player_id,
            series_winner_name: series_winner_name
        }
    end

    def games_completed
        pick_subject_games.select { |g| g.status == 'complete' }.count
    end

    # All players tied for the highest score. More than one means a tie.
    def series_leaders
        return [] if players.empty?

        top = players.map { |p| p.score.to_i }.max
        players.select { |p| p.score.to_i == top }
    end

    # Decide whether the series is over. Called after any game completes.
    #   - majority clinch: someone reached score_to_win -> they win immediately
    #   - games exhausted with a single leader -> that leader wins
    #   - otherwise (games left, or a tie after exhaustion) -> stays in progress,
    #     letting the host start the next/sudden-death game.
    def evaluate_series!
        return if series_status == 'complete'

        leaders = series_leaders
        top = leaders.first&.score.to_i

        if top >= score_to_win.to_i && leaders.count == 1
            finish_series!(leaders.first)
        elsif games_completed >= total_games.to_i && leaders.count == 1
            finish_series!(leaders.first)
        end
    end

    def series_winner_name
        Player.where(id: series_winner_player_id).first&.name
    end

    def process_player_disconnected(player_id)
        if self.my_turn_player_id == player_id
            self.increment_my_turn_player_id
        end

        if self.host_player_id == player_id
            self.host_player_id = self.my_turn_player_id
        end

        self.player_turn_order.delete(player_id)

        self.save
    end

    def increment_my_turn_player_id
        previous_index = self.player_turn_order.index(self.my_turn_player_id)

        next_index = (previous_index + 1) % self.player_turn_order.count
        
        self.my_turn_player_id = self.player_turn_order[next_index]

        self.save
    end

    def current_game
        pick_subject_games.
            select { |g| g.status == "in_progress" }.
            sort_by { |g| g.created_at }.
            last
    end

    def host_player_name
        Player.where(id: host_player_id).first&.name
    end

    def my_turn_player_name
        Player.where(id: my_turn_player_id).first&.name
    end

    private

    def finish_series!(winner)
        self.series_status = 'complete'
        self.series_winner_player_id = winner.id
        save
    end
end