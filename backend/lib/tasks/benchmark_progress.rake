namespace :task do
    desc 'タスク進捗率の順次処理と並列処理の性能を比較する'

    task benchmark_progress: :environment do
        logger = Rails.logger
        logger.level = Logger::DEBUG

        summary_log = []
        start_time = Time.current

        logger.info("バッチ処理開始: タスク進捗率集計 (#{start_time.strftime('%F %T')})")

        Organization.find_each do |organization|
            logger.info "💥順次処理: #{organization.name}"

            sequential_time = Benchmark.realtime do
                organization.users.find_each do |user|
                    total_tasks = user.tasks.where(organization_id: organization.id).count
                    completed_tasks = user.tasks.where(organization_id: organization.id, status: '完了').count
    
                    progress_rate = if total_tasks.positive?
                        (completed_tasks.to_f / total_tasks * 100).round(2)
                    else
                        0.0
                    end
                    sleep(0.5)

                    logger.debug "ユーザー: #{user.username}, 完了率: #{progress_rate}%"
    
                    TaskProgress.find_or_initialize_by(user_id: user.id, workspace_id: organization.id).tap do |tp|
                        tp.total_tasks = total_tasks
                        tp.completed_tasks = completed_tasks
                        tp.progress_rate = progress_rate
                        if tp.save
                            logger.debug "✅ 保存成功: #{tp.user.username}"
                        else
                            logger.warn "❌ 保存失敗: #{tp.errors.full_messages.join(', ')}"
                        end                      
                    end
                end
            end

            logger.info "順次処理時間: #{sequential_time.round(2)}秒"

            logger.info "💥 並列処理: #{organization.name}"

            parallel_time = Benchmark.realtime do
                Parallel.each(organization.users, in_threads: 4) do |user|
                    total_tasks = user.tasks.where(organization_id: organization.id).count
                    completed_tasks = user.tasks.where(organization_id: organization.id, status: '完了').count
    
                    progress_rate = if total_tasks.positive?
                        (completed_tasks.to_f / total_tasks * 100).round(2)
                    else
                        0.0
                    end
                    sleep(0.5)

                    logger.debug "ユーザー: #{user.username}, 完了率: #{progress_rate}%"
    
                    TaskProgress.find_or_initialize_by(user_id: user.id, workspace_id: organization.id).tap do |tp|
                        tp.total_tasks = total_tasks
                        tp.completed_tasks = completed_tasks
                        tp.progress_rate = progress_rate
                        if tp.save
                            logger.debug "✅ 保存成功: #{tp.user.username}"
                        else
                            logger.warn "❌ 保存失敗: #{tp.errors.full_messages.join(', ')}"
                        end                      
                    end
                end
            end
            logger.info "並列処理時間: #{parallel_time.round(2)}秒"

            summary_log << "■ ワークスペース: #{organization.name}"
            summary_log << "・順次処理時間: #{sequential_time.round(2)}秒"
            summary_log << "・並列処理時間: #{parallel_time.round(2)}秒"
            summary_log << ""
        end

        File.open("log/progress_summary.log","a") do |f|
            f.puts("📝 タスク進捗集計サマリー (#{start_time.strftime('%F %R')} 実行)")
            f.puts
            summary_log.each { |line| f.puts line }
            f.puts "--------------------------------------------"
        end

        logger.info 'バッチ処理終了: 全ワークスペース処理完了'
    end
end