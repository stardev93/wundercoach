class CoachesController < ApplicationController
  authorize_resource
  before_action :set_coach, only: %i(show edit update destroy removeimage)

  # GET /coaches
  def index
    @coaches = Coach.all.by_name.page(params[:page])
    @coaches = @coaches.where("lastname LIKE :pattern OR firstname LIKE :pattern OR email LIKE :pattern", pattern: "%#{params[:search]}%") if params[:search]
  end

  # GET /coaches/1
  def show
    @events = @coach.events.future_events.includes(:coaches).page(params[:page])
    @events = @events.where("name LIKE :pattern", pattern: "%#{params[:search]}%") if params[:search]
  end

  # GET /coaches/new
  def new
    @coach = Coach.new
  end

  # GET /coaches/1/edit
  def edit; end

  # POST /coaches
  def create
    @coach = Coach.new(coach_params)
    if @coach.save
      redirect_to @coach, notice: I18n.t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /coaches/1
  def update
    if @coach.update(coach_params)
      redirect_to @coach, notice: I18n.t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /coaches/1
  def removeimage
    @coach.image = nil
    @coach.save
    redirect_to coach_path(@coach), notice: I18n.t(:delete_image_successful)
  end

  # DELETE /coaches/1
  def destroy
    @coach.destroy
    redirect_to coaches_url, notice: I18n.t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_coach
    @coach = Coach.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def coach_params
    params.require(:coach).permit(:lastname, :firstname, :tel, :gender, :email, :price, :price_unit, :active, :image, :title, :homepage_url, :homepage_url_target_blank, :label, :description)
  end
end
