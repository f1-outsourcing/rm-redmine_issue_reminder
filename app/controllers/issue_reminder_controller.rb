
class IssueReminderController < ApplicationController
  before_action :find_project
  before_action :authorize

  def index
    @issues = find_reminder_issues
  end

  def send_reminders
    @issues = find_reminder_issues
    days_before_due = Setting.plugin_redmine_issue_reminder['days_before_due'].to_i
    @issues.each do |issue|
      IssueReminderMailer.issue_reminder(issue, days_before_due).deliver_now
    end
    flash[:notice] = l(:notice_reminders_sent, count: @issues.count)
    redirect_to project_issue_reminder_path(@project)
  rescue => e
    Rails.logger.error "Error sending reminders: #{e.message}"
    flash[:error] = l(:error_sending_reminders)
    redirect_to project_issue_reminder_path(@project)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_reminder_issues
    days_before_due = Setting.plugin_redmine_issue_reminder['days_before_due'].to_i
    due_date = Date.today + days_before_due.days
    @project.issues.open.where(due_date: due_date)
  end

  def reminder_threshold_date
    Setting.plugin_redmine_issue_reminder['reminder_days'].to_i.days.ago
  end
end
