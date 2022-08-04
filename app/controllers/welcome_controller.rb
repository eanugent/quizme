class WelcomeController < ApplicationController
  def index
  end

  def audio
    filename = {
      "31ljk23tjkl235l" => "good_times.mp3"
    }[params.require(:id)]

    send_file Rails.root.join('lib', 'assets', filename)
  end
end
