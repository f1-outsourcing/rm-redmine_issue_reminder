class IssueReminderController < ApplicationController
  before_action :find_project
  before_action :authorize
  before_action :set_days_before_due

  def index
    @issues = find_reminder_issues
  end

  def send_reminders
    @issues = find_reminder_issues
    sent_count = 0
    @issues.each do |issue|
      begin
        IssueReminderMailer.issue_reminder(issue, @days_before_due).deliver_now
        sent_count += 1
      rescue => e
        logger.error "Failed to send reminder for issue ##{issue.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
    flash[:notice] = l(:notice_reminders_sent, count: sent_count)
    redirect_to project_issue_reminder_path(@project, days_before_due: @days_before_due)
  rescue => e
    logger.error "Error sending reminders: #{e.message}\n#{e.backtrace.join("\n")}"
    flash[:error] = l(:error_sending_reminders)
    redirect_to project_issue_reminder_path(@project, days_before_due: @days_before_due)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def set_days_before_due
    @days_before_due = (params[:days_before_due] || Setting.plugin_redmine_issue_reminder['days_before_due']).to_i
    @days_before_due = 7 if @days_before_due <= 0 # Default to 7 days if the value is invalid
  end

  def find_reminder_issues
    due_date = Date.today + @days_before_due.days
    @project.issues.open.where('due_date <= ?', due_date).order(due_date: :asc)
  end
end

    due_date = Date.today + @days_before_due.days
    @project.issues.open.where('due_date <= ?', due_date).order(due_date: :asc)
  end
end
