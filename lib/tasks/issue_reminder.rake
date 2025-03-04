namespace :redmine do
  namespace :issue_reminder do
    desc 'Send reminders for issues due soon'
    task :send_reminders => :environment do
      days_since = Setting.plugin_redmine_issue_reminder['reminder_assigndays'].to_i * 30
      date_since = Date.today - days_since.days 

      # due dates
      days_before_due = Setting.plugin_redmine_issue_reminder['days_before_due'].to_i
      reminder_date = Date.today + days_before_due.days

      issues = Issue.open
          .where('due_date <= ? AND due_date > ?', reminder_date, date_since)
          .order(due_date: :asc)
      
      issues.each do |issue|
        puts "sending due date email #{issue.id}"
        IssueReminderMailer.issue_reminder(issue, days_before_due, "due").deliver_now
        #TestMailer.test_email.deliver_now
      end
      puts "Sent reminders for #{issues.count} issues due in #{days_before_due} days."

      # updated dates
      days_assign = Setting.plugin_redmine_issue_reminder['reminder_assigndays'].to_i
      days_freq = Setting.plugin_redmine_issue_reminder['reminder_fromfreqdays'].to_i
      days_no_updates = Setting.plugin_redmine_issue_reminder['reminder_fromdays'].to_i
      date_no_update = Date.today + days_no_updates.days

      issues = Issue.open
          #.where('(due_date IS NULL AND created_on > DATE_SUB(CURDATE(),INTERVAL ? day) AND updated_on > ? AND updated_on <= ? AND  MOD(DATEDIFF(CURDATE(), updated_on), ?) = 0)', days_create, days_since, date_no_update, days_freq)
          .where('(due_date IS NULL AND updated_on > ? AND updated_on <= ? AND MOD(DATEDIFF(CURDATE(), updated_on), ?) = 0)', date_since, date_no_update, days_freq)
          .where.not(assigned_to_id: nil)
          .order(due_date: :asc)
      
      issues.each do |issue|

        # Find the most recent assignee change
        assignment_journal = issue.journals
                             .joins(:details)
                             .where(journal_details: { property: 'attr', prop_key: 'assigned_to_id' })
                             .order('journals.created_on DESC')
                             .first

        # Check if issue was assigned at creation
        if assignment_journal.nil? && issue.assigned_to_id.present?
          assigned_time = issue.created_on
        else
          assigned_time = assignment_journal ? assignment_journal.created_on : 'N/A'
        end

        if ( (Date.today - days_assign) > assigned_time.to_date )
          puts "sending updated email #{issue.id}"
          IssueReminderMailer.issue_reminder(issue, 0, "updated").deliver_now
          #TestMailer.test_email.deliver_now
        end 
      end



    end
  end
end

