class IssueReminderMailer < Mailer
  def self.issue_reminder(issue, days_before_due)
    to = issue.assigned_to.is_a?(Group) ? issue.assigned_to.users : issue.assigned_to
    @issue = issue
    @days_before_due = days_before_due
    @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text']
    mail(to: to.map(&:mail),
         subject: "#{l(:label_reminder)}: #{issue.subject} (Due in #{days_before_due} days)",
         from: Setting.mail_from)
  end
end
