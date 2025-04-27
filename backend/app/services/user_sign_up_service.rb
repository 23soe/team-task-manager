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
        @organization_id = params[:organization_name]
        @errors = []
    end

    def call
        ActiveRecord::Base.transaction do
            if @user.save
                if @organization_id.present?
                    organization = Organization.find_by(id: @organization_name)
                    raise ActiveRecord::RecordNotFound, "指定された組織が存在しません。" unless organization

                    UserOrganization.create!(user: @user, organization: organization)
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
