class RandomSetsController < ApplicationController
  before_action :check_loggin?, only: [ :edit ]

  # GET /random_sets or /random_sets.json
  def index
    @random_sets = RandomSet.all

    @search = RandomSet.ransack(params[:q])
    @search.sorts = "id desc" if @search.sorts.empty?
    @random_sets = @search.result
  end

  # GET /random_sets/1 or /random_sets/1.json
  def show
    @random_set = RandomSet.find(params[:id])
    # ModおよびValiant用
    if @random_set.parent.present?
      @parent_set = RandomSet.find(@random_set.parent)
    end
    @lotteries = @random_set.lotteries.select(:id, :name, :dict, :reality, :default_check, :default_pickup, :value)
  end

  # GET /random_sets/new
  def new
    @random_set = RandomSet.new
  end

  # GET /random_sets/1/edit
  def edit
    @random_set = RandomSet.find(params[:id])
    @lotteries = @random_set.lotteries.select(:id, :name, :dict, :reality, :default_check, :default_pickup, :value)
    @search = @lotteries.ransack(params[:q])
    @search.sorts = "id asc" if @search.sorts.empty?
    @lotteries = @search.result
  end

  def edit_elements
    @random_set = RandomSet.find(params[:id])
  end

  # POST /random_sets or /random_sets.json
  def create
    @random_set = RandomSet.new(random_set_params)
      if @random_set.save
        reset_session
        remember(@random_set, params[:random_set][:password])
        log_in(@random_set)
        render turbo_stream: turbo_stream.action(:redirect, edit_random_set_path(@random_set))
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
        end
      end
  end

  # PATCH/PUT /random_sets/1 or /random_sets/1.json
  def update
    @random_set = RandomSet.find(params[:id])
    respond_to do |format|
      if @random_set.update(random_set_params)
        format.turbo_stream { flash.now.notice = @random_set.name.to_s + "を更新しました。" }
        format.html { render "update" }
      else
        format.turbo_stream { flash.now.alert = "更新に失敗しました。" }
        format.html { render "edit", status: :unprocessable_entity }
      end
    end
  end

  def create_list
    @random_set = RandomSet.find(params[:id])
    case params[:target_list]
      when "reality_list"
        @random_set.rate.push({"reality" => params[:reality], "value" => params[:value] })
      when "pickup_list"
        @random_set.pickup_list({"reality" => params[:reality], "value" => params[:value] })
      when "value_list"
        @random_set.value_list({"reality" => params[:reality], "value" => params[:value] })
    end

    respond_to do |format|
      if @random_set.save
        format.turbo_stream { flash.now.notice = @random_set.name.to_s + "に追加されました。" }
        forget.html { render "new_list" }
      else
        # format.turbo_stream { flash.now.alert = }
      end
    end

    
  end

  # DELETE /random_sets/1 or /random_sets/1.json
  def destroy
    @random_set.destroy!

    respond_to do |format|
      format.html { redirect_to random_sets_path, status: :see_other, notice: "Random set was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_random_set
      @random_set = RandomSet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def random_set_params
      params.require(:random_set).permit(:name, :dict, :password, :pick_type, :rate, :pickup_rate, :value)
    end
end
