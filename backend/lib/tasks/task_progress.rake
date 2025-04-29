namespace :task do
    desc 'ワークスペースごとに、担当者ごとのタスク進捗率を集計する'
    task aggregate_progress: :environment do
        puts 'バッチ処理開始: ワークスペースごとの担当者タスク進捗率を集計'

        Organization.find_each do |organization|
            puts "ワークスペース: #{organization.name}"

            organization.users.find_each do |user|
                total_tasks = user.tasks.where(organization_id: organization.id).count
                completed_tasks = user.tasks.where(organization_id: organization.id, status: '完了').count

                progress_rate = if total_tasks.positive?
                    (completed_tasks.to_f / total_tasks * 100).round(2)
                else
                    0.0
                end
                puts "ユーザー: #{user.username}, タスク数: #{total_tasks}, 完了タスク数: #{completed_tasks}, 進捗率: #{progress_rate}%"

                TaskProgress.find_or_initialize_by(user_id: user.id, workspace_id: organization.id).tap do |tp|
                    tp.total_tasks = total_tasks
                    tp.completed_tasks = completed_tasks
                    tp.progress_rate = progress_rate
                    tp.save!
                end
            end
        end

        puts 'バッチ処理終了: ワークスペースごとの担当者タスク進捗率を集計'
    end
end