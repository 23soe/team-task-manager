class Api::V1::TasksController < ApplicationController
    before_action :authorize_request
    before_action :set_workspace, only: [:index, :create]
  
    def index
        workspace = Organization.find(params[:workspace_id])
        render json: TaskService.tasks_with_users(workspace)
    end
  
    def create
        task = TaskService.create_task(@workspace, task_params)
        render json: task.as_json(include: { users: { only: [:id, :username] } }), status: :created
    rescue => e
        Rails.logger.error "🔥 Controller Error: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
    end
  
    def update
        task = Task.find(params[:id])
        updated_task = TaskService.update_task(task, task_update_params)
        render json: updated_task.as_json(include: { users: { only: [:id, :username] } }), status: :ok
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end
  
    def destroy
        task = Task.find(params[:id])
        TaskService.destroy_task(task)
        head :no_content
    rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
    end
  
    private
  
    def set_workspace
        @workspace = Organization.find(params[:workspace_id])
    end
  
    def task_params
        params.permit(:title, :contents, :due_date, :category, :status, user_ids: [])
            .merge(organization_id: @workspace.id)
    end
  
    def task_update_params
        params.permit(:title, :contents, :due_date, :category, :status, user_ids: [])
    end
end
