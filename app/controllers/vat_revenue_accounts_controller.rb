class VatRevenueAccountsController < ApplicationController
  before_action :set_vat_revenue_account, only: %i(show edit update destroy)

  # GET /vat_revenue_accounts
  def index
    current_tenant.vats.each do |vat|
      VatRevenueAccount.create ({
          :vat_id => vat.id,
          :revenue_account => '00000'
        })
    end
    @vat_revenue_accounts = if params[:search]
      VatRevenueAccount.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      VatRevenueAccount.page(params[:page]).order('name ASC')
    end
  end

  # # GET /vat_revenue_accounts/1
  # def show
  # end
  #
  # GET /vat_revenue_accounts/new
  def new
    @vat_revenue_account = VatRevenueAccount.new
  end

  # GET /vat_revenue_accounts/1/edit
  def edit
  end

  # POST /vat_revenue_accounts
  def create
    @vat_revenue_account = VatRevenueAccount.new(vat_revenue_account_params)
    if @vat_revenue_account.save
      redirect_to vat_revenue_accounts_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /vat_revenue_accounts/1
  def update
    if @vat_revenue_account.update(vat_revenue_account_params)
      redirect_to vat_revenue_accounts_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /vat_revenue_accounts/1
  def destroy
    @vat_revenue_account.destroy
    redirect_to vat_revenue_accounts_url, notice: t(:delete_successful)
  end

  private

  def set_vat_revenue_account
    @vat_revenue_account = VatRevenueAccount.find(params[:id])
  end

  def vat_revenue_account_params
    params.require(:vat_revenue_account).permit(:account_id, :vat_id, :name, :revenue_account)
  end
end
