class Crm::ContactDetailsController < ApplicationController
  before_action :set_crm_contact_detail, only: %i(show edit update destroy)

  # GET /crm/contact_details
  def index
    redirect_to crm_contacts_path
    #authorize_feature! 'contact_manager'
    @contact_details = if params[:search]
      Contact detail.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Contact detail.page(params[:page]).order('name ASC')
    end
  end

  # GET /crm/contact_details/1
  def show
    authorize_feature! 'contact_manager'
  end

  # GET /crm/contact_details/new
  def new
    authorize_feature! 'contact_manager'
    @crm_contact_detail = Crm::ContactDetail.new
    @crm_contact_detail.contact = Crm::Contact.find(params[:contact_id])
    @crm_contact_detail.account = @crm_contact_detail.contact.account
  end

  # GET /crm/contact_details/1/edit
  def edit
    authorize_feature! 'contact_manager'
  end

  # POST /crm/contact_details
  def create
    authorize_feature! 'contact_manager'
    @crm_contact_detail = Crm::ContactDetail.new(crm_contact_detail_params)
    if @crm_contact_detail.save
      redirect_to crm_contact_path(@crm_contact_detail.contact)+'#details', notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /crm/contact_details/1
  def update
    authorize_feature! 'contact_manager'
    if @crm_contact_detail.update(crm_contact_detail_params)
      redirect_to crm_contact_path(@crm_contact_detail.contact)+'#details', notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /crm/contact_details/1
  def destroy
    authorize_feature! 'contact_manager'
    @contact = @crm_contact_detail.contact
    @crm_contact_detail.destroy
    redirect_to crm_contact_path(@contact)+'#details', notice: t(:delete_successful)
  end

  private

  def set_crm_contact_detail
    @crm_contact_detail = Crm::ContactDetail.find(params[:id])
  end

  def crm_contact_detail_params
    params.require(:crm_contact_detail).permit(:account_id, :contact_id, :detail_value, :detail_type)
  end
end
