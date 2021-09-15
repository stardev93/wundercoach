class ContactstatusesController < ApplicationController
  before_action :set_contactstatus, only: %i(show edit update destroy)
  authorize_resource

  # GET /contactstatuses
  # GET /contactstatuses.json
  def index
    @contactstatuses = Contactstatus.all
  end

  # GET /contactstatuses/1
  # GET /contactstatuses/1.json
  def show; end

  # GET /contactstatuses/new
  def new
    @contactstatus = Contactstatus.new
  end

  # GET /contactstatuses/1/edit
  def edit; end

  # POST /contactstatuses
  # POST /contactstatuses.json
  def create
    @contactstatus = Contactstatus.new(contactstatus_params)

    respond_to do |format|
      if @contactstatus.save
        format.html { redirect_to @contactstatus, notice: t(:creation_successful) }
        format.json { render action: 'show', status: :created, location: @contactstatus }
      else
        format.html { render action: 'new' }
        format.json { render json: @contactstatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contactstatuses/1
  # PATCH/PUT /contactstatuses/1.json
  def update
    respond_to do |format|
      if @contactstatus.update(contactstatus_params)
        format.html { redirect_to @contactstatus, notice: t(:update_successful) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contactstatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contactstatuses/1
  # DELETE /contactstatuses/1.json
  def destroy
    @contactstatus.destroy
    respond_to do |format|
      format.html { redirect_to contactstatuses_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contactstatus
    @contactstatus = Contactstatus.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contactstatus_params
    params.require(:contactstatus).permit(:name, :comments, :key)
  end
end
