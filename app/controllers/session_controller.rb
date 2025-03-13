class SessionController < ApplicationController
  def new
    @random_set = RandomSet.find(params[:random_set])
    # @session = @random_set
  end

  def create
    @current_set = RandomSet.find(params[:random_set])
      if @current_set&.authenticate(params[:password])
        reset_session
        remember(@current_set)
        log_in @current_set
        render turbo_stream: turbo_stream.action(:redirect, edit_random_set_path(@current_set))
      else
        flash[:warning] = "パスワードが異なります"
        render turbo_stream: turbo_stream.action(:redirect, random_set_path(@current_set))
      end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
