class CompaniesController < ApplicationController
  before_action :set_company, only: %i(show edit update destroy)
  authorize_resource

  # GET /companies
  def index
    if params[:search]
      @companies = Company.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      @companies = Company.page(params[:page]).order('name ASC')
    end
  end

  # GET /companies/1
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      redirect_to @company, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to companies_url, notice: t(:delete_successful)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def company_params
      params.require(:company).permit(:account_id, :name, :name_addon, :comments, :zip, :city, :street, :streetno, :country, :gender, :firstname, :lastname, :tel1, :tel2, :fax, :email, :homepage, :logo, :companystatus_id, :companynumber, :vat_number)
    end
end
