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
    
    private

    def authorize_request
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        
        begin
            decoded = JsonWebToken.decode(header)
            @current_user = User.find(decoded[:user_id])if decoded
            render json: { errors: ['Invalid token'] }, status: :unauthorized unless @current_user
        rescue ActiveRecord::RecordNotFound, JWT::DecodeError
            render json: { errors: ['Invalid token'] }, status: :unauthorized
        end
    end
end
  