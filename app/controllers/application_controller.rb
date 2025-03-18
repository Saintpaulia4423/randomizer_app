class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include ApplicationHelper
  include SessionHelper
  def check_loggin?
    if current_set_session.nil?
      redirect_to root_path
    else
      true
    end
  end
end
