module Admin
  class GameTypesController < BaseController
    def index
      render json: { data: Subject.distinct.order(:game_type).pluck(:game_type) }
    end
  end
end
