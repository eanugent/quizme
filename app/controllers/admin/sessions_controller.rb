module Admin
  class SessionsController < ApplicationController
    include AdminAuthentication

    protect_from_forgery with: :exception

    def show
      render json: { authenticated: admin_authenticated? }
    end

    def create
      username = params[:username].to_s
      password = params[:password].to_s

      if valid_admin_credentials?(username, password)
        session[:admin_authenticated] = true
        render json: { authenticated: true }
      else
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end

    def destroy
      session.delete(:admin_authenticated)
      head :no_content
    end
  end
end
