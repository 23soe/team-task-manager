class Api::V1::TaskProgressesController < ApplicationController
    def index
        workspace_id = params[:workspace_id]
        progress = TaskProgress.includes(:user).where(workspace_id: workspace_id)
      
        render json: progress.map { |p|
            {
                id: p.user.id,
                username: p.user.username,
                total_tasks: p.total_tasks,
                completed_tasks: p.completed_tasks,
                progress_rate: p.progress_rate
            }
        }
    end      
end