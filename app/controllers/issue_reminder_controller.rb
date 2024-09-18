class IssueReminderController < ApplicationController
  before_action :find_project
  before_action :authorize
  before_action :set_days_before_due
  
  def index
    @days_before_due = params[:days_before_due].to_i
    @days_before_due = Setting.plugin_redmine_issue_reminder['days_before_due'].to_i if @days_before_due.zero?
    @issues = find_reminder_issues
  end

  def send_reminders
    @issues = find_reminder_issues
    days_before_due = params[:days_before_due].to_i
    @issues.each do |issue|
      IssueReminderMailer.issue_reminder(issue, days_before_due).deliver_now
    end
    flash[:notice] = l(:notice_reminders_sent, count: @issues.count)
    redirect_to project_issue_reminder_path(@project, days_before_due: days_before_due)
  rescue => e
    Rails.logger.error "Error sending reminders: #{e.message}\n#{e.backtrace.join("\n")}"
    flash[:error] = l(:error_sending_reminders)
    redirect_to project_issue_reminder_path(@project, days_before_due: days_before_due)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_reminder_issues
    due_date = Date.today + @days_before_due.days
    @project.issues.open.where('due_date <= ?', due_date).order(due_date: :asc)
  end

  def set_days_before_due
    @days_before_due = (params[:days_before_due] || Setting.plugin_redmine_issue_reminder['days_before_due']).to_i
    @days_before_due = 7 if @days_before_due <= 0 # Default to 7 days if the value is invalid
  end
  
  def reminder_threshold_date
    Setting.plugin_redmine_issue_reminder['reminder_days'].to_i.days.ago
  end
end
