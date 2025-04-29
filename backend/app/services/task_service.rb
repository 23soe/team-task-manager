class TaskService
    def self.tasks_with_users(workspace)
        # 🚀 N+1問題防止
        # tasksとusersを同時に読み込む（includes）ことで、タスクごとに個別クエリが発生するのを防ぐ
        # SQLクエリ数を最小限にしてパフォーマンス向上    # 1回のSQLクエリでtasksとusersを取得できる
        workspace.tasks.includes(:users).map do |task|
            {
                id: task.id,
                title: task.title,
                contents: task.contents,
                due_date: task.due_date,
                status: task.status,
                category: task.category,
                user_ids: task.users.map(&:id) # 🎯 userの配列ではなくidだけ配列で渡す
            }
        end
    end

    def self.create_task(workspace, params)
        task = workspace.tasks.build(
            title: params[:title],
            contents: params[:contents],
            due_date: params[:due_date],
            status: params[:status],
            category: params[:category],
            organization_id: workspace.id
        )
    
        task.user_ids = params[:user_ids] if params[:user_ids] 
    
        unless task.valid?
            Rails.logger.error "🔥 VALIDATION ERROR (SAVE前) : #{task.errors.full_messages}"
        end
    
        begin
            task.save!
        rescue => e
            Rails.logger.error "🔥 SAVE失敗: #{e.message}"
            Rails.logger.error "🔥 SAVE失敗エラー内容: #{task.errors.full_messages}"
            raise e
        end
    
        task
    end

    def self.update_task(task, params)
        task.assign_attributes(
            title: params[:title],
            contents: params[:contents],
            due_date: params[:due_date],
            status: params[:status],
            category: params[:category]
        )
    
        task.user_ids = params[:user_ids] if params[:user_ids].present?
    
        unless task.valid?
          Rails.logger.error "🔥 UPDATE VALIDATION ERROR : #{task.errors.full_messages}"
        end
    
        task.save!
        task
    end
    
    def self.destroy_task(task)
        task.task_users.destroy_all if task.task_users.present?
        
        unless task.destroy
            Rails.logger.error "🔥 DELETE VALIDATION ERROR: #{task.errors.full_messages}"
            raise ActiveRecord::RecordInvalid.new(task)
        end
    end
end
  