class WorkspacesController < ApplicationController
    before_action :authorize_request

    def index
        workspaces = @current_user.organizations.select(:id, :name)
        render json: { workspace: workspaces }, status: :ok
    end
end
