class SessionController < ApplicationController
  def new
    @random_set = RandomSet.find(params[:random_set_id])
  end

  def create
    @current_set = RandomSet.find(params[:random_set_id])
    if session[:set_id] = @current_set.id && @current_set&.authenticate(params[:session][:password])
      reset_session
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
        format.html { render "new", status: :unprocessable_entity }
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
