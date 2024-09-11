Rails.application.routes.draw do
  resources :projects do
    get 'issue_reminder', to: 'issue_reminder#index'
    post 'issue_reminder/send_reminders', to: 'issue_reminder#send_reminders'
  end
end
