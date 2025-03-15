module SessionHelper
  def logged_in?
    !current_set_session.nil?
  end

  def log_in(random_set)
    session[:session_token] = random_set.session_digest
  end

  # セッションの検証を行い、RandomSetに登録されているセッションと合致していればパススルー
  def current_set_session
    get_random_set()
    if (session_token = session[:session_token])
      if @random_set && session[:session_token] == @random_set.session_digest
        @current_set = @random_set
      end
    end
  end

  def remember(random_set)
    random_set.remember
    cookies.permanent.encrypted[:session_token] = random_set.session_digest
  end
  def get_random_set
    @random_set = RandomSet.find(params[:random_set_id]) if params[:random_set_id].present?
    @random_set = RandomSet.find(params[:id]) if @random_set.nil?
  end
end
