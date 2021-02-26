Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'submissions#index'
  post '/', to: 'submissions#index'
  get 'submissions/download_submission_file', to: 'submissions#download_submission_file'
  get 'submissions/api_response_attestation_clinic_file_download', to: 'submissions#api_response_attestation_clinic_file_download'
  get 'submissions/api_response_errors_download_csv_file', to: 'submissions#api_response_errors_download_csv_file'
  post 'submissions/api_submit_submission_file', to: 'submissions#api_submit_submission_file'
  # root 'homes#show'

  resource :login

  resource :submission
end
