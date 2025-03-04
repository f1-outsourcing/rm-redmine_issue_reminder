class IssueReminderMailer < ActionMailer::Base
  default from: Setting.mail_from

  def self.issue_reminder(issue, days_before_due, type)
    Rails.logger.info "Preparing reminder email for issue ##{issue.id}"

    to = []
    if issue.assigned_to.is_a?(Group)
      to = issue.assigned_to.users.map(&:mail).compact
    elsif issue.assigned_to.is_a?(User) && issue.assigned_to.mail.present?
      to = [issue.assigned_to.mail]
    elsif issue.author && issue.author.mail.present?
      to = [issue.author.mail] # Fallback to the issue author if no assignee
    end

    # Call the mailer instance method and return the mail object
    IssueReminderMailer.with(issue: issue, days_before_due: days_before_due, to: to, type: type).issue_reminder
  end

  def issue_reminder
    issue = params[:issue]
    days_before_due = params[:days_before_due]
    to = params[:to]
    type = params[:type]

    @issue = issue
    @days_before_due = days_before_due || 7 # Default to 7 days if empty?
    if type == "updated"
      @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text_fromdays'].to_s
    else
      @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text'].to_s
    end

    Rails.logger.info "Sending reminder email for issue ##{@issue.id} to #{to.join(', ')}"

    # Ensure non-nil values
    if to.nil? || to.empty?
      Rails.logger.warn "Recipient email address list is empty."
      return
    end

    mail(to: to, subject: "##{issue.id} #{issue.subject}", body: "#{@reminder_text}")

  end
end

