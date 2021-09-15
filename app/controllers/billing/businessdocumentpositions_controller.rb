class Billing::BusinessdocumentpositionsController < ApplicationController
  before_action :set_businessdocumentposition, only: %i(show edit update destroy)
  authorize_resource

  # # GET /assets
  # def index
  #   @asset = Asset.new
  #   @assets = Asset.page(params[:page]).order('name ASC')
  #   @assets = @assets.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  # end
  #
  # # GET /assets/1
  # def show; end

  # GET /assets/new
  def new
    @businessdocumentposition = Billing::Businessdocumentposition.new
    @businessdocument = Billing::Businessdocument.find(params[:id])
    @businessdocumentposition.businessdocument = @businessdocument

    @q = Event.ransack(params[:q])
    @q.sorts = ['start_date ASC', 'events.name ASC'] if @q.sorts.empty?
    @events = @q.result(distinct: true).includes(:onlinestatus, :planningstatus, :eventtype)

    @q = BundleEvent.ransack(params[:q])
    @q.sorts = ['start_date DESC', 'events.name ASC'] if @q.sorts.empty?
    @bundleevents = @q.result(distinct: true)

    @q = Item.ransack(params[:q])
    @q.sorts = ['name ASC'] if @q.sorts.empty?
    @items = @q.result(distinct: true)
    #.includes(:onlinestatus, :planningstatus, :eventtype)
  end

  # GET /businessdocumentpositions/1/edit
  def edit; end

  # POST /businessdocumentpositions
  def create
    @businessdocumentposition = Billing::Businessdocumentposition.new(billing_businessdocumentposition_params)

    if @businessdocumentposition.save
      redirect_to billing_businessdocument_path(@businessdocumentposition.businessdocument), notice: 'Position was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /businessdocumentpositions/1
  def update
    if @businessdocumentposition.update(billing_businessdocumentposition_params)
      respond_to do |format|
        format.html { render json: Billing::BusinessdocumentpositionDecorator.decorate(@businessdocumentposition.decorate) }
        #redirect_to billing_businessdocument_path(@businessdocumentposition.businessdocument), notice: 'Position was successfully updated.'
        format.json { render json: Billing::BusinessdocumentpositionDecorator.decorate(@businessdocumentposition.decorate) }
      end

    else
      render action: 'edit'
    end
  end

  # DELETE /businessdocumentpositions/1
  def destroy
    @businessdocument = @businessdocumentposition.businessdocument
    @businessdocumentposition.destroy
    redirect_to url, notice: 'Position was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_businessdocumentposition
    @businessdocumentposition = Billing::Businessdocumentposition.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def billing_businessdocumentposition_params
    params.require(:billing_businessdocumentposition).permit(:name, :description, :position, :amount, :unit, :vat_id, :price_cents)
  end
end
