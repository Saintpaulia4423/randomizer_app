class LotteriesController < ApplicationController
  before_action :get_random_set, only: [ :new, :create, :edit, :update, :destroy, :index, :show ]
  before_action :check_lottery, only: [ :edit, :update, :destroy ]
  before_action :check_loggin?, only: [ :create, :update, :destroy ]

  def new
    @lottery = Lottery.new()
    @action_path = random_set_lotteries_path
  end

  def create
    @lottery = @random_set.lotteries.build(lottery_params)
    respond_to do |format|
      if @lottery.save
        format.turbo_stream { flash.now.notice = "作成しました。" }
        format.html { redirect_to edit_random_set_path, notice: "作成しました。" }
        # format.html { render turbo_stream: turbo_stream.action(:redirect, edit_random_set_path(@current_set)) }
        # flash.now.notice = "作成しました。"
      else
        flash.now.alert = "失敗しました。"
        # @seamera.empty?
        @action_path = random_set_lotteries_path
        format.turbo_stream { render "new", status: :unprocessable_entity }
        format.html { render "new", status: :unprocessable_entity }
      end
    end
  end

  def index
    @search = @random_set.lotteries.ransack(params[:q])
    @search.sorts = "reality desc" if @search.sorts.empty?
    @lotteries = @search.result

    @random_set_title = @random_set.name
  end

  def edit
    @action_path = random_set_lottery_path
  end

  def update
    respond_to do |format|
      if @lottery.update(lottery_params)
        format.turbo_stream { flash.now.notice = @lottery.name.to_s + "は更新されました。" }
        format.html { redirect_to edit_random_set_path, notice: @lottery.name.to_s + "は更新されました。" }
      else
        @action_path = random_set_lottery_path
        puts "miss lot"
        format.turbo_stream { render "edit", status: :unprocessable_entity }
        format.html { render "edit", status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # テスト実装のため削除なし
    # @lottery.destroy!
    flash.now.notice = "削除しました"
  end

  private
    def check_lottery
      @lottery = Lottery.find(params[:id])
    end

    def lottery_params
      params.require(:lottery).permit(:name, :dict, :reality, :default_check, :default_pickup, :value, :origin_id)
    end
end
