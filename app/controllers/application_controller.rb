class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  if Rails.env.development?
    allow_browser versions: {}
  else
    allow_browser versions: :modern
  end
end
