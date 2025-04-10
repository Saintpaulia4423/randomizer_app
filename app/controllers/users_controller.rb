class UsersController < ApplicationController
  before_action :check_user_loggin?, only: %i[show edit update destroy destroy_list]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        reset_session
        user_remember(@user)
        user_log_in(@user)
        format.turbo_stream { flash.now.notice = @user.user_id + "を作成しました。" }
        render turbo_stream: turbo_stream.action(:redirect, user_path(@user))
      else
        format.turbo_stream { flash.now.alert = "作成に失敗しました。" }
        format.html { render "new", status: :unprocessable_entity }
      end
    end
  end

  def show
    @user = User.find(params[:id])
    @favorities = @user.favorite_all
    @created = @user.created_all
  end

  def edit
  end

  def update
  end

  def destroy
    @user = User.find_by(id: params[:id])
    user_log_out
    @user.destroy! unless @user.nil?
    render turbo_stream: turbo_stream.action(:redirect, root_path)
  end

  def destroy_list
    user = User.find(params[:id])
    @target_set = RandomSet.find_by(id: params[:random_set_id])
    case params[:list_mode]
    when "favorite"
      user.delete_favorite(@target_set)
      respond_to do |format|
        @destroy_list_target = "favorite"
        format.turbo_stream { flash.now.notice = @target_set.name.to_s + "をお気に入りから削除しました。" }
        format.html { render "destroy_favorite", deleted_id: @target_set.id }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:user_id, :password)
    end
end
