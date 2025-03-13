module SessionHelper
  def logged_in?
    !current_set_session.nil?
  end

  def log_in(random_set)
    session[:session_token] = random_set.session_digest
  end

  # セッションの検証を行い、RandomSetに登録されているセッションと合致していればパススルー
  def current_set_session
    if (session_token = session[:session_token])
      set = RandomSet.find(params[:id]) if params[:id].present?
      set = RandomSet.find(params[:random_set]) if params[:random_set].present?
      if set && session[:session_token] == set.session_digest
        @current_set = set
      end        
    end
  end

  def remember(random_set)
    random_set.remember
    cookies.permanent.encrypted[:session_token] = random_set.session_digest
  end
end
