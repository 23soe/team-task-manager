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
    
    def recalculate
        workspace_id = params[:workspace_id]
        if workspace_id.present?
            system("bundle exec rake task:aggregate_progress[#{workspace_id}]")
            head :ok
        else
            render json: { error: 'workspace_id is required' }, status: :bad_request
        end
    end
end