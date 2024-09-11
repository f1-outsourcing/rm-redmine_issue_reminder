namespace :redmine do
  namespace :issue_reminder do
    desc 'Send reminders for issues due soon'
    task :send_reminders => :environment do
      days_before_due = Setting.plugin_redmine_issue_reminder['days_before_due'].to_i
      reminder_date = Date.today + days_before_due.days

      issues = Issue.open.where(due_date: reminder_date)
      
      issues.each do |issue|
        IssueReminderMailer.issue_reminder(issue, days_before_due).deliver_now
      end

      puts "Sent reminders for #{issues.count} issues due in #{days_before_due} days."
    end
  end
end
