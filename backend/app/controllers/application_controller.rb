class ApplicationController < ActionController::API
    include ActionController::Helpers

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
