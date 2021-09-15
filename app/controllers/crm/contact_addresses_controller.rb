class Crm::ContactAddressesController < ApplicationController
  before_action :set_contact_address, only: %i(show edit update destroy primary)

  # GET /contact_addresses
  def index
    redirect_to crm_contacts_path
    # authorize_feature! 'contact_manager'
    # @contact_addresses = Crm::ContactAddress.all
    # @contact_addresses = Contact address.page(params[:page]).order('id ASC')
    @contact_addresses = if params[:search]
      Crm::ContactAddress.where('street LIKE ?', "%#{params[:search]}%").page(params[:page]).order('city ASC, street ASC')
    else
      Crm::ContactAddress.page(params[:page]).order('city ASC, street ASC')
    end
  end

  # GET /contact_addresses/1
  def show
    authorize_feature! 'contact_manager'
  end

  # GET /contact_addresses/new
  def new
    authorize_feature! 'contact_manager'
    @contact_address = Crm::ContactAddress.new
    @contact_address.contact = Crm::Contact.find(params[:contact_id])
  end

  # GET /contact_addresses/1/edit
  def edit
    authorize_feature! 'contact_manager'
  end

  # GET /contact_addresses/1/primary
  def primary
    authorize_feature! 'contact_manager'
    @contact_address.make_primary
    redirect_to crm_contact_path(@contact_address.contact), notice: t(:creation_successful)
  end

  # POST /contact_addresses
  def create
    authorize_feature! 'contact_manager'
    @contact_address = Crm::ContactAddress.new(contact_address_params)
    if @contact_address.save
      redirect_to crm_contact_path(@contact_address.contact)+'#addresses', notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /contact_addresses/1
  def update
    authorize_feature! 'contact_manager'
    if @contact_address.update(contact_address_params)
      redirect_to crm_contact_path(@contact_address.contact)+'#addresses', notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /contact_addresses/1
  def destroy
    authorize_feature! 'contact_manager'
    @contact = @contact_address.contact
    @contact_address.destroy
    redirect_to crm_contact_path(@contact_address.contact)+'#addresses', notice: t(:delete_successful)
  end

  private

  def set_contact_address
    @contact_address = Crm::ContactAddress.find(params[:id])
  end

  def contact_address_params
    params.require(:crm_contact_address).permit(:account_id, :contact_id, :street, :zip, :city, :country, :address_type, :is_primary)
  end
end
