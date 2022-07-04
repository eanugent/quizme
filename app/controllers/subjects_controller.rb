class SubjectsController < ActionController::Base
    def show
        render json: { data: subject, status: :ok}
    end

    def index
        render json: { data: subjects, status: :ok }
    end

    private

    def id_param
        params.require(:subject_id).to_i
    end

    def game_type_param
        params.require(:game_type)
    end

    def subject
        Subject.find(id_param)
    end

    def subjects
        Subject.where(game_type: game_type_param).to_a.sort_by{|s| s.name}
    end
end
