class IssueReminderController < ApplicationController
    before_action :find_project_by_project_id
    before_action :authorize
  
    def index
      @issues = find_reminder_issues
    end
  
    def send_reminders
      issues = find_reminder_issues
      issues.each do |issue|
        IssueReminderMailer.issue_reminder(issue).deliver_now
      end
      redirect_to project_issue_reminder_path(@project), notice: l(:notice_reminders_sent)
    end
  
    private
  
    def find_reminder_issues
      @project.issues.open.where('updated_on < ?', reminder_threshold_date)
    end
  
    def reminder_threshold_date
      Setting.plugin_redmine_issue_reminder['reminder_days'].to_i.days.ago
    end
  end
  