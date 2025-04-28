class RegistrationsController < ApplicationController
    def create
        organization_names = params[:organization_names] || []
        result = RegistrationService.new(signup_params, organization_names).call
        
        if result[:success]
            render json: { user: result[:user] }, status: :created
        else
            render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
    end

    private

    def signup_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
end
