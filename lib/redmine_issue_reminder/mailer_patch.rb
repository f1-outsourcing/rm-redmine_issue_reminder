module RedmineIssueReminder
  module MailerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :issue_reminder, :issue_reminder
      end
    end

    module InstanceMethods
      def issue_reminder(issue)
        @issue = issue
        @reminder_text = Setting.plugin_redmine_issue_reminder['reminder_text']
        mail(to: issue.assigned_to.mail,
             subject: "#{l(:label_reminder)}: #{issue.subject}",
             from: Setting.mail_from)
      end
    end
  end
end

unless Mailer.included_modules.include?(RedmineIssueReminder::MailerPatch)
  Mailer.send(:include, RedmineIssueReminder::MailerPatch)
end
