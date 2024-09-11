class CreateIssueReminders < ActiveRecord::Migration[5.2]
    def change
      create_table :issue_reminders do |t|
        t.references :issue, foreign_key: true, null: false
        t.datetime :last_reminded_at
        t.timestamps
      end
    end
  end
  