class SessionController < ApplicationController
  def new
    reject_params_by_session_mode if params[:session_mode].nil?
    case params[:session_mode]
    when "random_set"
      @random_set = RandomSet.find(params[:id])
    when "user"
    end
  end

  def create
    reject_params_by_session_mode if params[:session][:session_mode].nil?
    case params[:session][:session_mode]
    when "random_set"
      @current_set = RandomSet.find(params[:id])
      if @current_set.id && @current_set&.authenticate(params[:session][:password])
        keep_reset_session("random_set")
        remember(@current_set, params[:session][:password])
        log_in @current_set
        render turbo_stream: turbo_stream.action(:redirect, edit_random_set_path(@current_set))
      else
        respond_to do |format|
          message = "パスワードが異なります"
          if params[:session][:password].blank?
            message = "パスワードを入力してください"
          end
          format.turbo_stream { flash.now.alert = message }
          format.html { render "new", status: :unprocessable_entity, params: "random_set" }
        end
      end
    when "user"
      @current_user = User.find_by(user_id: params[:session][:user_id])
      if @current_user.id && @current_user&.authenticate(params[:session][:password])
        keep_reset_session("user")
        user_remember(@current_user)
        user_log_in @current_user
        render turbo_stream: turbo_stream.action(:redirect, user_path(@current_user))
      else
        respond_to do |format|
          message = "パスワードが異なります"
          if params[:session][:password].blank?
            message = "パスワードを入力してください"
          end
          format.turbo_stream { flash.now.alert = message }
          format.html { render "new", status: :unprocessable_entity, params: "user" }
        end
      end
    end
  end

  def destroy
    reject_params_by_session_mode if params[:session_mode].nil?
    case params[:session_mode]
    when "random_set"
      set_log_out if logged_in?
      render turbo_stream: turbo_stream.action(:redirect, random_sets_path)
    when "user"
      user_log_out if user_logged_in?
      render turbo_stream: turbo_stream.action(:redirect, root_path)
    end      
  end

  def reject_params_by_session_mode
    respond_to do |format|
      message = "不適正な情報です。処理を再度やり直してください。"
      format.turbo_stream { flash.now.alert = message }
      format.html { render "new", status: :unprocessable_entity }
    end
  end
end
