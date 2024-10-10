class IssueReminderController < ApplicationController
  before_action :find_project
  before_action :authorize
  before_action :set_days_before_due

  def index
    @issues = find_reminder_issues
    logger.info "Found #{@issues.count} issues for reminder in project #{@project.identifier}"
  end

  def send_reminders
    @issues = find_reminder_issues
    sent_count = 0
    error_count = 0

    logger.info "Attempting to send reminders for #{@issues.count} issues in project #{@project.identifier}"

    @issues.each do |issue|
      begin
        logger.info "Processing reminder for issue ##{issue.id}"
        mail = IssueReminderMailer.issue_reminder(issue, @days_before_due)
        if mail
          mail.deliver_now
          sent_count += 1
          logger.info "Successfully sent reminder for issue ##{issue.id}"
        else
          error_count += 1
          logger.warn "No recipients for reminder of issue ##{issue.id}"
        end
      rescue => e
        error_count += 1
        logger.error "Failed to send reminder for issue ##{issue.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end

    if sent_count > 0
      flash[:notice] = l(:notice_reminders_sent, count: sent_count)
    end
    
    if error_count > 0
      flash[:warning] = l(:warning_some_reminders_not_sent, count: error_count)
    end

    logger.info "Reminder process completed. Sent: #{sent_count}, Errors: #{error_count}"
    redirect_to project_issue_reminder_path(@project, days_before_due: @days_before_due)
  rescue => e
    logger.error "Error in send_reminders action: #{e.message}\n#{e.backtrace.join("\n")}"
    flash[:error] = l(:error_sending_reminders)
    redirect_to project_issue_reminder_path(@project, days_before_due: @days_before_due)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
    logger.info "Found project: #{@project.identifier}"
  end

  def set_days_before_due
    @days_before_due = (params[:days_before_due] || Setting.plugin_redmine_issue_reminder['days_before_due']).to_i
    @days_before_due = 7 if @days_before_due <= 0 # Default to 7 days if the value is invalid
    logger.info "Days before due set to: #{@days_before_due}"
  end

  def find_reminder_issues
    due_date = Date.today + @days_before_due.days
    issues = @project.issues.open.where('due_date <= ?', due_date).order(due_date: :asc)
    logger.info "Found #{issues.count} issues due before or on #{due_date}"
    issues
  end
end
