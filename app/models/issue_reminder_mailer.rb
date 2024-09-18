class IssueReminderMailer < Mailer
  def self.issue_reminder(issue, days_before_due)
    @issue = issue
    @days_before_due = days_before_due || 7 # Default to 7 days if nil
    @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text']

    recipients = if issue.assigned_to.is_a?(Group)
                   issue.assigned_to.users.map(&:mail)
                 elsif issue.assigned_to.is_a?(User)
                   [issue.assigned_to.mail]
                 else
                   [issue.author.mail] # Fallback to the issue author if no assignee
                 end

    mail(to: recipients,
         subject: "#{l(:label_reminder)}: #{issue.subject} (Due in #{@days_before_due} days)",
         from: Setting.mail_from)
  end
end
