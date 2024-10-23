class IssueReminderMailer < Mailer
  def self.issue_reminder(issue, days_before_due)
    Rails.logger.info "Preparing reminder email for issue ##{issue.id}"
    
    to = []
    if issue.assigned_to.is_a?(Group)
      to = issue.assigned_to.users.map(&:mail).compact
    elsif issue.assigned_to.is_a?(User) && issue.assigned_to.mail.present?
      to = [issue.assigned_to.mail]
    elsif issue.author && issue.author.mail.present?
      to = [issue.author.mail] # Fallback to the issue author if no assignee
    end

    new.issue_reminder(issue, days_before_due, to)
  end

  def issue_reminder(issue, days_before_due, to)
    @issue = issue
    @days_before_due = days_before_due || 7 # Default to 7 days if empty?
    @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text'].to_s

    Rails.logger.info "Sending reminder email for issue ##{@issue.id} to #{to.join(', ')}"

    mail(to: to,
         subject: "#{l(:label_reminder)}: #{issue.subject} (Due in #{@days_before_due} days)") do |format|
      format.text
      format.html
    end
  end
end

 puts "Reminder subject: #{subject.inspect}"
 puts "Reminder template: #{template_name.inspect}"
end
