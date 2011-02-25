class ScheduleMailer < Mailer
  def schedule(recipients, project, issues, days, language)
    set_language_if_valid language
    recipients recipients
    subject l(:mail_subject_schedule, :count => issues.size, :days => days)
    body :issues => issues,
         :days => days,
         :issues_url => url_for(:controller => 'issues', :action => 'calendar', :project_id => project)
    render_multipart('schedule', body)
  end

  # Sends schedules to recipients
  # Available options:
  # * :recipients => recipients of mail (defaults to root)
  # * :days     => how many days in the future to remind about (defaults to 7)
  # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
  # * :project  => id or identifier of project to process (defaults to all projects)
  def self.schedules(options={})
    recipients = options[:recipients] || "root"
    days = options[:days] || 7
    language = options[:language] || "en"
    project = options[:project] ? Project.find(options[:project]) : nil
    tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil

    s = ARCondition.new ["#{IssueStatus.table_name}.is_closed = ? AND #{Issue.table_name}.due_date <= ?", false, days.day.from_now.to_date]
    s << "#{Issue.table_name}.assigned_to_id IS NOT NULL"
    s << "#{Project.table_name}.status = #{Project::STATUS_ACTIVE}"
    s << "#{Issue.table_name}.project_id = #{project.id}" if project
    s << "#{Issue.table_name}.tracker_id = #{tracker.id}" if tracker

    issues = Issue.find(:all, :include => [:status, :assigned_to, :project, :tracker], :conditions => s.conditions, :order => "#{Issue.table_name}.due_date ASC")
    deliver_schedule(recipients, project, issues, days, language)
  end
end
