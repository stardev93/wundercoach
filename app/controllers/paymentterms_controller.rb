class PaymenttermsController < ApplicationController
  before_action :set_paymentterm, only: %i(show edit update destroy)

  # GET /paymentterms
  def index
    # @paymentterms = Paymentterm.all
    # @paymentterms = Paymentterm.page(params[:page]).order('id ASC')
    @paymentterms = Paymentterm.with_translations(I18n.locale).page(params[:page]).order('context ASC, name')
    @paymentterms = @paymentterms.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
      #.where('name LIKE ?', "%#{params[:search]}%")
    # else
    #   Paymentterm.page(params[:page]).order('name ASC')
    # end
  end

  # GET /paymentterms/1
  def show
  end

  # GET /paymentterms/new
  def new
    @paymentterm = Paymentterm.new
  end

  # GET /paymentterms/1/edit
  def edit
  end

  # POST /paymentterms
  def create
    @paymentterm = Paymentterm.new(paymentterm_params)
    if @paymentterm.save
      redirect_to @paymentterm, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /paymentterms/1
  def update
    if @paymentterm.update(paymentterm_params)
      redirect_to @paymentterm, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /paymentterms/1
  def destroy
    @paymentterm.destroy
    redirect_to paymentterms_url, notice: t(:delete_successful)
  end

  private

  def set_paymentterm
    @paymentterm = Paymentterm.find(params[:id])
  end

  def paymentterm_params
    params.require(:paymentterm).permit(:account_id, :paymentmethod_id, :name, :description)
  end
end
