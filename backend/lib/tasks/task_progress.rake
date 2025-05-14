namespace :task do
    desc 'ワークスペースごとに、担当者ごとのタスク進捗率を集計する'

    task aggregate_progress: [:workspace_id] => :environment do |t, args|
        TaskProgressAggregator.run(args[:workspace_id], parallel: true)
    end
end