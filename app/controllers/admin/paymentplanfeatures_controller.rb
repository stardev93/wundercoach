class Admin::PaymentplanfeaturesController < Admin::AdminController
  before_action :set_paymentplanfeature, only: %i(show edit update destroy chooseplan setvalue)
  authorize_resource

  def index
    @appversions = Appversion.all

    # session.delete(:current_appversion)
    if params[:appversion]
      session[:current_appversion] = Appversion.find(params[:appversion]).id
    else
      @appversion = Appversion.order('version_number DESC').first
      session[:current_appversion] = @appversion.id
    end
    @paymentplans = @appversion.paymentplans
    @features = @appversion.features.order('position ASC')
  end

  def setappversion
    @appversion = Appversion.find(params[:id])
    session[:current_appversion] = @appversion.id
    redirect_to admin_paymentplanfeatures_path
  end

  # GET /paymentplanfeatures/1
  # GET /paymentplanfeatures/1.json
  def show; end

  def position; end

  # GET /paymentplanfeatures/new
  def new
    @paymentplanfeature = Paymentplanfeature.new
  end

  # GET /brand_units/1/edit
  def edit; end

  # POST /paymentplanfeatures
  # POST /paymentplanfeatures.json
  def create
    @paymentplanfeature = Paymentplanfeature.new(paymentplanfeature_params)

    respond_to do |format|
      if @paymentplanfeature.save
        format.html { render partial: "link_destroy", locals: { paymentplanfeature: @paymentplanfeature } } # render delete button as its an ajax-request
        format.json { render action: 'show', status: :created, location: @paymentplanfeature }
      else
        format.html { render action: 'new' }
        format.json { render json: @paymentplanfeature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /paymentplanfeatures/1
  # PATCH/PUT /paymentplanfeatures/1.json
  def update
    respond_to do |format|
      if @paymentplanfeature.update(paymentplanfeature_params)
        format.html { redirect_to @paymentplanfeature, notice: 'Rate-Function was successfully updated.' }
        format.json { render json: @paymentplanfeature.fieldvalue }
      else
        format.html { render action: 'edit' }
        format.json { render json: @paymentplanfeature.errors, status: :unprocessable_entity }
      end
    end
  end

  # set a new value for paymentplan
  def setvalue
    @paymentplanfeature.fieldvalue = if @paymentplanfeature.fieldvalue.to_i == 1
                                       0
                                     else
                                       1
    end
    @paymentplanfeature.save
    respond_to do |format|
      if @paymentplanfeature.fieldvalue.to_i == 1
        format.html { render partial: "link_destroy", locals: { paymentplanfeature: @paymentplanfeature } } # render delete button as its an ajax-request
      else
        format.html { render partial: "link_create", locals: { paymentplanfeature: @paymentplanfeature } } # render delete button as its an ajax-request
      end
      format.json { head :no_content }
    end
  end

  # DELETE /paymentplanfeatures/1
  # DELETE /paymentplanfeatures/1.json
  def destroy
    @paymentplanfeature.destroy
    redirect_to paymentplanfeatures_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentplanfeature
    @paymentplanfeature = Paymentplanfeature.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentplanfeature_params
    params.permit(:paymentplan_id, :feature_id, :value)
  end
end
