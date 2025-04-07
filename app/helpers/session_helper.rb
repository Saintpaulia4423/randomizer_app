module SessionHelper
  # random_set
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

  def remember(random_set, password)
    random_set.remember
    cookies.permanent[:set_id] = random_set.id
    cookies.permanent.encrypted[:session_token] = random_set.session_digest
    cookies.permanent.encrypted[:password_token] = password
  end
  def get_random_set
    @random_set = RandomSet.find(params[:random_set_id]) if params[:random_set_id].present?
    @random_set = RandomSet.find(params[:id]) if @random_set.nil?
  end
  def get_session_password
    cookies.encrypted[:password_token]
  end
  def set_log_out
    cookies.permanent[:set_id] = nil
    set = RandomSet.find_by(session_digest: session[:session_token])
    set.forget
    session[:session_token] = nil
  end

  # user
  def user_log_in(user)
    session[:user_session_token] = user.session_digest
  end
  def current_user_session
    @user = User.find_by(id: cookies[:user_session_id])
    if session_token = session[:user_session_token]
      if @user && session[:user_session_token] == @user.session_digest
        @current_user = @user
      end
    end
  end
  def user_remember(user)
    user.remember
    cookies.permanent[:user_session_id] = user.id
  end
  def user_log_out
    cookies.permanent[:user_id] = nil
    user = User.find_by(session_digest: session[:user_session_token])
    user.forget
    session[:user_session_token] = nil
  end

  # ユーティリティー
  # reset_session処理、ユーザーログインはキープする。
  def keep_reset_session
    if defined?(sesison[:user_session_token]).present?
      cache = session.dup 
      reset_session
      session[:user_session_token] = cache[:user_session_token]
      session[:user_session_id] = cache[:user_session_id]
    else
      reset_session
    end
  end
  # 各種ログインチェック
  def logged_in?
    !current_set_session.nil?
  end
  def user_logged_in?
    !current_user_session.nil?
  end
  # セッションモードの判定
  def session_mode_check
    defined?(params[:session][:session_mode]).nil? ? params[:session_mode] : params[:session][:session_mode]
  end
end
