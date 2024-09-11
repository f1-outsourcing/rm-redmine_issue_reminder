class IssueReminderMailer < Mailer
    def issue_reminder(issue)
      @issue = issue
      @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text']
      mail(to: issue.assigned_to.mail,
           subject: "#{l(:label_reminder)}: #{issue.subject}",
           from: Setting.mail_from)
    end
  end
  