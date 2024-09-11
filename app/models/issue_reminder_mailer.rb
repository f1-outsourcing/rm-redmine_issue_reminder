class IssueReminderMailer < Mailer
  def self.issue_reminder(issue)
    to = issue.assigned_to.is_a?(Group) ? issue.assigned_to.users : issue.assigned_to
    @issue = issue
    @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text']
    mail(to: to.map(&:mail),
         subject: "#{l(:label_reminder)}: #{issue.subject}",
         from: Setting.mail_from)
  end
end
