class RandomSetsController < ApplicationController
  before_action :check_loggin?, only: [ :edit, :update, :destroy, :create_list, :update_list, :destroy_list ]

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


  # レアリティ抽選などのリスト用処理
  def new_list
    @action_path = create_list_path
    @random_set = RandomSet.find(params[:id])
    case params[:target_list]
    when "reality_list"
      @have_list =  @random_set.rate.map { |item| item["reality"] }
    when "pickup_list"
      @have_list =  @random_set.pickup_rate.map { |item| item["reality"] }
    when "value_list"
      @have_list = @random_set.value_list.map { |item| item["reality"] }
    end
  end

  def create_list
    @random_set = RandomSet.find(params[:id])
    @target_list = params[:random_set][:target_list]
    case params[:random_set][:target_list]
    when "reality_list"
      @random_set.rate.push({ "reality" => params[:random_set][:reality].to_i, "value" => params[:random_set][:value].to_i })
    when "pickup_list"
      @random_set.pickup_rate.push({ "reality" => params[:random_set][:reality].to_i, "value" => params[:random_set][:value].to_i })
    when "value_list"
      @random_set.value_list.push({ "reality" => params[:random_set][:reality].to_i, "value" => params[:random_set][:value].to_i })
    end

    respond_to do |format|
      if @random_set.save
        format.turbo_stream { flash.now.notice = @random_set.name.to_s + "に追加されました。" }
        format.html { render "create_list" }
      else
        format.turbo_stream { flash.now.alert = "追加に失敗しました。" }
        format.html { render "new_list", status: :unprocessable_entity }
      end
    end
end

  def edit_list
    @random_set = RandomSet.find(params[:id])
    @action_path = update_list_path
  end

  def update_list
    @random_set = RandomSet.find(params[:id])
    @target_list = params[:random_set][:target_list]
    begin
      case params[:random_set][:target_list]
      when "reality_list"
        target_data = @random_set.rate.filter { |item| item["reality"] == params[:random_set][:reality].to_i }
        target_data[0]["value"] = params[:random_set][:value].to_i
      when "pickup_list"
        target_data = @random_set.pickup_rate.filter { |item| item["reality"] == params[:random_set][:reality].to_i }
        target_data[0]["value"] = params[:random_set][:value].to_i
      when "value_list"
        target_data = @random_set.value_list.filter { |item| item["reality"] == params[:random_set][:reality].to_i }
        target_data[0]["value"] = params[:random_set][:value].to_i
      end
    rescue
      respond_to do |format|
        format.turbo_stream { flash.now.alert = "不正な値が書き込まれたため、失敗しました。" }
        format.html { render "edit_list", status: :unprocessable_entity }
        return 0
      end
    end

    respond_to do |format|
      if @random_set.save
        format.turbo_stream { flash.now.notice = @random_set.name.to_s + "に追加されました。" }
        format.html { render "update_list" }
      else
        format.turbo_stream { flash.now.alert = "更新に失敗しました。" }
        format.html { render "edit_list", status: :unprocessable_entity }
      end
    end
  end

  def destroy_list
    @random_set = RandomSet.find(params[:id])
    @target_list = params[:target_list]
    begin
      case params[:target_list]
      when "reality_list"
        target_index = @random_set.rate.find_index { |item| item["reality"] == params[:reality].to_i }
        @random_set.rate.delete_at(target_index)
      when "pickup_list"
        target_index = @random_set.pickup_rate.find_index { |item| item["reality"] == params[:reality].to_i }
        @random_set.pickup_rate.delete_at(target_index)
      when "value_list"
        target_index = @random_set.value_list.find_index { |item| item["reality"] == params[:reality].to_i }
        @random_set.value_list.delete_at(target_index)
      end
    rescue
      respond_to do |format|
        format.turbo_stream { flash.now.alert = "不正な値が書き込まれたため、失敗しました。" }
        format.html { render "destroy_list", status: :unprocessable_entity }
        return 0
      end
    end
    puts target_index

    respond_to do |format|
      if @random_set.save
        format.turbo_stream { flash.now.notice = @random_set.name.to_s + "から削除されました。" }
        format.html { render "destroy_list" }
      else
        format.turbo_stream { flash.now.alert = "削除に失敗しました。" }
        format.html { render "destroy_list", status: :unprocessable_entity }
      end
    end
  end

  # DELETE /random_sets/1 or /random_sets/1.json
  def destroy
    respond_to do |format|
      if @random_set.destroy!
        format.turbo_stream { flash.notice = "削除しました。" }
        render turbo_stream: turbo_stream.action(:redirect, random_sets_path)
      else
        format.turbo_stream { flash.now.alert = "削除に失敗しました。" }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_random_set
      @random_set = RandomSet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def random_set_params
      params.require(:random_set).permit(:name, :dict, :password, :pick_type, :rate, :pickup_rate, :value, :default_value)
    end
end
