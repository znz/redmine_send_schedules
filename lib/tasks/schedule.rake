desc <<-END_DESC
Send schedules about issues due in the next days.

Available options:
  * recipients => recipients of mail (defaults to root)
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)
  * language => "en" or "ja"

Example:
  rake redmine:send_schedules recipients=you@example.com days=7 RAILS_ENV="production" language=ja
END_DESC

namespace :redmine do
  task :send_schedules => :environment do
    options = {}
    options[:recipients] = ENV['recipients'] if ENV['recipients']
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']
    options[:language] = ENV['language'] if ENV['language']

    ScheduleMailer.schedules(options)
  end
end
