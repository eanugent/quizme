class GameRoom < ApplicationRecord
    has_many :players    

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
end