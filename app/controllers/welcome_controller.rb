class WelcomeController < ApplicationController
  def index
    gon.game_id = params[:game_id]
  end
end
