class UsersController < ApplicationController
  before_action :check_user_loggin?, only: %i[show edit update destroy destroy_list]
  def new
    @user = User.new
  end

  # turbo_frame modalからのログインフォームから離脱するため
  def pass_new
    render turbo_stream: turbo_stream.action(:redirect, new_user_path)
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        reset_session
        user_remember(@user)
        user_log_in(@user)
        format.turbo_stream { flash.now.notice = @user.user_id + "を作成しました。" }
        format.html { render "show" }
      else
        # format.turbo_stream { flash.now.alert = "作成に失敗しました。" }
        format.html { render :new, status: :unprocessable_entity, params: "user"  }
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
  end

  def destroy_list
    user = User.find(params[:id])
    @target_set = RandomSet.find_by(id: params[:random_set_id])
    case params[:list_mode]
    when "favorite"
      user.delete_favorite(@target_set)
      respond_to do |format|
        format.turbo_stream { flash.now.info = @target_set.name "をお気に入りから削除しました。" }
        format.html { render "destroy_favorite" }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:user_id, :password)
    end
end
