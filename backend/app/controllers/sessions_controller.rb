class SessionsController < ApplicationController
    before_action :authorize_request, only: [:me]

    def create
        user = User.find_by(email: params[:email])
    
        if user&.authenticate(params[:password])
            toekn = JsonWebToken.encode(user_id: user.id)
            render json: { token: toekn, user: { id: user.id, email: user.email, username: user.username} }, status: :ok
        else
            render json: { errors: ["Invalid email or password"] }, status: :unauthorized
        end
    end
  
    def destroy
        session[:user_id] = nil
        render json: { message: "Logged out successfully" }
    end

    def me
        render json: { user: { id: @current_user.id, email: @current_user.email, username: @current_user.username } }, status: :ok
    end
end
  