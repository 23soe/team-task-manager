class Api::V1::TasksController < ApplicationController
    before_action :authorize_request

    def index
        workspace = Organization.find(params[:workspace_id])
        workspaces = workspace.tasks.includes(:users)

        render json: workspaces.as_json(include: { users: { only: [:id, :username] } })
    end
end
