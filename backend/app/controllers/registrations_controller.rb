class RegistrationsController < ApplicationController
    def create
        service = UserSignUpService.new(user_params)
        if service.call
            render json: { user: service.user }, status: :created
        else
            render json: { errors: service.errors }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :organization_id)
    end
end
