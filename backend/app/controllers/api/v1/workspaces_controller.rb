class Api::V1::WorkspacesController < ApplicationController
    before_action :authorize_request

    def index
        workspaces = @current_user.organizations.select(:id, :name)
        render json: { workspace: workspaces }, status: :ok
    end
    
    def show
        workspace = Organization.includes(:users).find(params[:id])
        render json: workspace.as_json(include: { users: { only: [:id, :username] } }), status: :ok
    end
end
