class CreateIssueReminders < ActiveRecord::Migration[5.2]
    def change
      create_table :issue_reminders do |t|
        t.references :issue, :null => false
        t.datetime :last_reminded_at
        t.timestamps
      end
    end
  end
  
