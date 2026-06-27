module Admin
  class BaseController < ApplicationController
    include AdminAuthentication

    protect_from_forgery with: :exception
    before_action :require_admin!

    private

    def game_type_param
      params.require(:game_type)
    end
  end
end
