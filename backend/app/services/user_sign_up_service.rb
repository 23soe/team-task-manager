class UserSignUpService
    attr_reader :user, :errors

    def initialize(params)
        @params = params
        @user = User.new(
            username: params[:username],
            email: params[:email],
            password: params[:password],
            password_confirmation: params[:password_confirmation]
        )
        @organization_id = params[:organization_id]
        @errors = []
    end

    def call
        ActiveRecord::Base.transaction do
            if @user.save
                if @organization_id.present?
                    UserOrganization.create!(user: @user, organization_id: @organization_id)
                end
                true
            else
                @errors = @user.errors.full_messages
                false
            end
        end
    rescue => e
        @errors = [e.message]
        false
    end
end
