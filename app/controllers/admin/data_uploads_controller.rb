class Admin::DataUploadsController < ApplicationController
  before_action :authenticate_admin

  def new
  end

  def create
    if params[:csv_file].present?
      begin
        csv_text = params[:csv_file].read
        process_csv(csv_text)
        flash[:notice] = "Data updated successfully!"
      rescue => e
        flash[:error] = "Error processing CSV: #{e.message}"
      end
    else
      flash[:error] = "Please select a CSV file."
    end
    render :new
  end

  private

  def authenticate_admin
    password = ENV['QUIZME_ADMIN_PASSWORD']
    if password.blank?
      render plain: "Admin password not configured.", status: :internal_server_error
      return
    end

    authenticate_or_request_with_http_basic do |username, p|
      p == password
    end
  end

  def process_csv(csv_text)
    require 'csv'
    csv = CSV.parse(csv_text, headers: true)
    subjects_headers = csv.headers.select { |h| h.to_s.start_with?("_") }

    cleared_types = []

    ActiveRecord::Base.transaction do
      csv.each do |row|
        next if row["Id"].blank? || row["Question"].blank?

        game_type = row["Game Type"]
        unless cleared_types.include?(game_type)
          clear_game_type(game_type)
          cleared_types << game_type
        end

        q = Question.create!(
          id: row["Id"],
          game_type: game_type,
          question: row["Question"],
          use_in_kahoot: row["Kahoot?"] == "1"
        )

        subjects_headers.each do |s|
          next if row[s].blank?
          name = s[1..].strip
          subject = Subject.find_or_create_by!(name: name, game_type: game_type)
          Answer.create!(question: q, subject: subject, answer_val: row[s])
        end
      end
    end
  end

  def clear_game_type(type)
    q_ids = Question.where(game_type: type).pluck(:id)
    Answer.where(question_id: q_ids).delete_all
    Question.where(id: q_ids).delete_all
    Subject.where(game_type: type).delete_all
  end
end
