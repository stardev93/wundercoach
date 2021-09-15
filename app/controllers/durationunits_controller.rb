class DurationunitsController < ApplicationController
  before_action :set_durationunit, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /durationunits
  def index
    #@durationunits = Durationunit.all
    #@durationunits = Durationunit.page(params[:page]).order('id ASC')

    if params[:search]
      @durationunits = Durationunit.with_translations(I18n.locale).where("name_singular LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name_singular ASC')
    else
      @durationunits = Durationunit.with_translations(I18n.locale).page(params[:page]).order('name_singular ASC')
    end
  end

  # GET /durationunits/1
  def show
  end

  # GET /durationunits/new
  def new
    @durationunit = Durationunit.new
  end

  # GET /durationunits/1/edit
  def edit
  end

  # POST /durationunits
  def create
    @durationunit = Durationunit.new(durationunit_params)

    if @durationunit.save
      redirect_to @durationunit, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /durationunits/1
  def update
    if @durationunit.update(durationunit_params)
      redirect_to @durationunit, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /durationunits/1
  def destroy
    @durationunit.destroy
    redirect_to durationunits_url, notice: t(:delete_successful)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_durationunit
      @durationunit = Durationunit.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def durationunit_params
      params.require(:durationunit).permit(:key, :name_plural, :name_singular, :description, :sortorder)
    end
end
