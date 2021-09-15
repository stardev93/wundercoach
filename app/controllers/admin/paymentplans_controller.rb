class Admin::PaymentplansController < Admin::AdminController
  before_action :set_paymentplan, only: %i(show edit update destroy)
  authorize_resource
  # skip_authorization_check only: :accountdata

  # GET /paymentplans
  def index
    @paymentplans = Paymentplan.page(params[:page])
  end

  # GET /paymentplans/1
  def show; end

  # GET /paymentplans/new
  def new
    @paymentplan = Paymentplan.new
  end

  # GET /paymentplans/1/edit
  def edit; end

  # POST /paymentplans
  def create
    @paymentplan = Paymentplan.new(paymentplan_params)
    if @paymentplan.save
      redirect_to paymentplans_path, notice: 'Paymentplan was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /paymentplans/1
  def update
    if @paymentplan.update(paymentplan_params)
      redirect_to admin_paymentplanfeatures_path, notice: 'Paymentplan was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /paymentplans/1
  def destroy
    @paymentplan.destroy
    redirect_to admin_paymentplans_url, notice: 'Paymentplan was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_paymentplan
    @paymentplan = Paymentplan.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def paymentplan_params
    params.require(:paymentplan).permit(:name, :comments, :key, :price, :sortorder, :discount, :description, :recommended, :cycle, :appversion_id)
  end

end
