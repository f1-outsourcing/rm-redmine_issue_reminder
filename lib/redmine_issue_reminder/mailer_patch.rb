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
          IssueReminderMailer.issue_reminder(issue)
        end
      end
    end
  end
  
  Rails.configuration.to_prepare do
    Mailer.send(:include, RedmineIssueReminder::MailerPatch)
  end
  