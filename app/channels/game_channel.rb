class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_for PickSubjectGame.find(params[:game_id])
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
