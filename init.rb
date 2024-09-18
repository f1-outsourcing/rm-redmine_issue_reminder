require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'issue_reminder_mailer'
end

Redmine::Plugin.register :redmine_issue_reminder do
  name 'Redmine Issue Reminder plugin'
  author 'L Stuiver'
  description 'Sends email reminders for issues that have not been updated recently'
  version '1.1.2'
  url 'https://github.com/KeKkEmEn/redmine_issue_reminder'
  author_url 'https://github.com/KeKkEmEn'

  settings default: {
    'days_before_due' => 3,
    'reminder_text' => 'This issue is due soon. Please update the status or add a comment.'
  }, partial: 'settings/issue_reminder_settings'

  project_module :issue_reminder do
    permission :view_issue_reminder, issue_reminder: :index
    permission :send_issue_reminder, issue_reminder: :send_reminders
  end
  
  menu :project_menu, :issue_reminder, 
       { controller: 'issue_reminder', action: 'index' }, 
       caption: :label_issue_reminder, 
       after: :issues, 
       param: :project_id
end


Rails.configuration.to_prepare do
  require_dependency 'redmine_issue_reminder/hooks'
  require_dependency 'redmine_issue_reminder/mailer_patch'
  require_dependency 'issue_reminder_mailer'
end
