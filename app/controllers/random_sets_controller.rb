class RandomSetsController < ApplicationController
  before_action :set_random_set, only: %i[ show edit update destroy ]

  # GET /random_sets or /random_sets.json
  def index
    @random_sets = RandomSet.all
  end

  # GET /random_sets/1 or /random_sets/1.json
  def show
  end

  # GET /random_sets/new
  def new
    @random_set = RandomSet.new
  end

  # GET /random_sets/1/edit
  def edit
  end

  # POST /random_sets or /random_sets.json
  def create
    @random_set = RandomSet.new(random_set_params)

    respond_to do |format|
      if @random_set.save
        format.html { redirect_to @random_set, notice: "Random set was successfully created." }
        format.json { render :show, status: :created, location: @random_set }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @random_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /random_sets/1 or /random_sets/1.json
  def update
    respond_to do |format|
      if @random_set.update(random_set_params)
        format.html { redirect_to @random_set, notice: "Random set was successfully updated." }
        format.json { render :show, status: :ok, location: @random_set }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @random_set.errors, status: :unprocessable_entity }
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
      params.require(:random_set).permit(:name, :parent, :data)
    end
end
