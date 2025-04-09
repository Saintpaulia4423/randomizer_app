class FavoriteController < ApplicationController
  # お気に入り関係
  def flip_favorite
    @user = User.find_by(id: cookies[:user_id])
    @random_set = RandomSet.find_by(id: params[:random_set_id])
    if @user.present? && @random_set.present?
      respond_to do |format|
        puts "favorte"
        if @user.flip_favorite(@random_set)
          @random_set = RandomSet.find(@random_set.id)
          format.turbo_stream { flash.now.notice = "お気に入りに追加しました。" }
          format.html { render "favorite_button" }
        else
          @random_set = RandomSet.find(@random_set.id)
          format.turbo_stream { flash.now.notice = "お気に入りから削除しました。" }
          format.html { render "favorite_button" }
        end
      end
    else
    end
  end
end
