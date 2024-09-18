class IssueReminderMailer < Mailer
  def self.issue_reminder(issue, days_before_due)
    to = if issue.assigned_to.is_a?(Group)
           issue.assigned_to.users.map(&:mail).compact
         elsif issue.assigned_to.is_a?(User) && issue.assigned_to.mail.present?
           [issue.assigned_to.mail]
         elsif issue.author && issue.author.mail.present?
           [issue.author.mail] # Fallback to the issue author if no assignee
         else
           [] # No valid recipients
         end

    return if to.empty?

    reminder_mail = new
    reminder_mail.issue_reminder(issue, days_before_due, to)
  end

  def issue_reminder(issue, days_before_due, to)
    @issue = issue
    @days_before_due = days_before_due || 7 # Default to 7 days if nil
    @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text'].to_s

    mail(to: to,
         subject: "#{l(:label_reminder)}: #{issue.subject} (Due in #{@days_before_due} days)")
  end
end
