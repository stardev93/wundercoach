class Admin::AffiliatesController < Admin::AdminController
  before_action :set_affiliate, only: %i(show edit update destroy)

  # GET /affiliates
  def index
    @affiliates = if params[:search]
                    Affiliate.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
                  else
                    Affiliate.page(params[:page]).order('name ASC')
    end
  end

  # GET /affiliates/1
  def show
    @accounts = @affiliate.accounts.page(params[:page])
    # @adpartners = @affiliate.adpartners.page(params[:page])
    # @eventlists = @affiliate.eventlists.page(params[:page])
    @events = @affiliate.events.page(params[:page]).includes(:affiliate_tags)
    # @tags = @affiliate.tags.page(params[:page])
    @orders = @affiliate.orders.page(params[:page])
  end

  # GET /affiliates/new
  def new
    @affiliate = Affiliate.new
  end

  # GET /affiliates/1/edit
  def edit; end

  # POST /affiliates
  def create
    @affiliate = Affiliate.new(affiliate_params)
    if @affiliate.save
      redirect_to @affiliate, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /affiliates/1
  def update
    if @affiliate.update(affiliate_params)
      redirect_to @affiliate, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /affiliates/1
  def destroy
    @affiliate.destroy
    redirect_to affiliates_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_affiliate
    @affiliate = Affiliate.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def affiliate_params
    params.require(:affiliate).permit(:name, :name_addon, :lastname, :firstname, :street, :zip, :city, :country, :email)
  end
end
