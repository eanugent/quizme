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
        }
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
end