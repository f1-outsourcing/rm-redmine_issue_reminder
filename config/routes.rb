Rails.application.routes.draw do
  resources :projects do
    resource :issue_reminder, only: [:index], controller: 'issue_reminder' do
      post 'send_reminders', on: :collection
    end
  end
end
