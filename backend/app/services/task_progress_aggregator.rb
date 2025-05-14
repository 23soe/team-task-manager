class TaskProgressAggregator
    def self.run(workspace_id = nil, parallel: false)
        target_orgs = workspace_id.present? ? Organization.where(id: workspace_id) : Organization.all
    
        target_orgs.find_each do |organization|
            users = organization.users.to_a

            handler = lambda do |user|
                total = user.tasks.where(organization_id: organization.id).count
                done = user.tasks.where(organization_id: organization.id, status: '完了').count
                rate = total.positive? ? (done.to_f / total*100).round(2) : 0.0

                TaskProgress.find_or_initialize_by(user_id: user.id, workspace_id: organization.id).tap do |tp|
                    tp.total_tasks = total
                    tp.completed_tasks = done
                    tp.progress_rate = rate
                    tp.save!
                end
            end

            if parallel
                Parallel.each(users, in_threads: 4) { |user| handler.call(user) }
            else
                users.each { |user| handler.call(user) }
            end
        end
    end
end