class RegistrationService

    def initialize(user_params, organization_names)
        @user_params = user_params
        @organization_names = organization_names || []
    end

    def call
        ActiveRecord::Base.transaction do
            # puts "受け取ったorganization_names: #{@organization_names}" 
            user = User.new(@user_params)
            
            if user.save
                @organization_names.each do |org_name|
                    organization = Organization.find_or_create_by!(name: org_name)
                    UserOrganization.create!(user: user, organization: organization)
                end
                { success: true, user: user }
            else
                { success: false, errors: user.errors.full_messages }
            end
        end
    rescue ActiveRecord::RecordInvalid => e
        { success: false, errors: [e.message] }
    end
end
