class LotteriesController < ApplicationController
  before_action :check_lottery, only: %i[ edit update destroy ]

  def new
    @lottery = Lottery.new
  end

  def create
    @lottery = current_set.lotteries.build(lottery_params)

    respond_to do |format|
      if @lottery.save
        format.html { redirect_to @lottery, notice: "要素を追加しました。" }
        format.json { render :show, status: :created, location: @lottery }
      else 
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lottery.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @lotteries = current_set.lotteries
  end

  def show
    @lottery = current_set.lotteries.find[:id]
  end

  def edit
  end

  def update
    respond_to do |format|
      if @lottery.update(lottery_params)
        format.html { redirect_to @lottery, notice: "要素を更新しました。" }
        format.json { render :show, status: :ok, location: @lottery }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lottery.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @lottery.destroy!

    respond_to do |format|
      format.html { redirect_to lottery_path, status: :see_other, notice: "要素を削除しました。" }
      format.json { head :no_content }
    end
  end

  private
    def check_lottery
      @lottery = Lottery.find(params[:id])
    end

    def lottery_params
      params.require(:lottery).permit(:name, :dict, :reality, :defalt_check)
    end
end
