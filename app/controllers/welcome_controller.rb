class WelcomeController < ApplicationController
  def index
    gon.room_key = params[:room_key]
  end
end
