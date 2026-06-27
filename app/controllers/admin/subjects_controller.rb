module Admin
  class SubjectsController < BaseController
    def index
      subjects = Subject.where(game_type: game_type_param).order(:name)
      render json: { data: subjects.map { |s| subject_summary(s) } }
    end

    def new_template
      render json: { data: { answers: question_answers_template(game_type_param) } }
    end

    def show
      render json: { data: subject_with_answers(subject) }
    end

    def create
      subject = Subject.new(name: params.require(:name), game_type: game_type_param)

      ActiveRecord::Base.transaction do
        subject.save!
        upsert_answers(subject, answers_param)
      end

      render json: { data: subject_with_answers(subject) }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end

    def update
      ActiveRecord::Base.transaction do
        subject.update!(name: params.require(:name)) if params[:name].present?
        upsert_answers(subject, answers_param) if params[:answers].present?
      end

      render json: { data: subject_with_answers(subject) }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end

    private

    def subject
      @subject ||= Subject.find(params[:id])
    end

    def answers_param
      params.require(:answers).map do |answer|
        answer.permit(:question_id, :answer_val)
      end
    end

    def subject_summary(subject)
      { id: subject.id, name: subject.name, game_type: subject.game_type }
    end

    def subject_with_answers(subject)
      questions = Question.where(game_type: subject.game_type).order(:id)
      answers_by_question_id = subject.answers.index_by(&:question_id)

      {
        id: subject.id,
        name: subject.name,
        game_type: subject.game_type,
        answers: questions.map do |question|
          {
            question_id: question.id,
            question: question.question,
            answer_val: answers_by_question_id[question.id]&.answer_val || 3
          }
        end
      }
    end

    def upsert_answers(subject, answers)
      answers.each do |answer_attrs|
        answer = subject.answers.find_or_initialize_by(question_id: answer_attrs[:question_id])
        answer.answer_val = answer_attrs[:answer_val]
        answer.save!
      end
    end

    def question_answers_template(game_type)
      Question.where(game_type: game_type).order(:id).map do |question|
        {
          question_id: question.id,
          question: question.question,
          answer_val: 3
        }
      end
    end
  end
end
