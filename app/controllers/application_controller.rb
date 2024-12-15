class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  if Rails.env.development?
    allow_browser versions: {}
  else
    allow_browser versions: :modern
  end
end
