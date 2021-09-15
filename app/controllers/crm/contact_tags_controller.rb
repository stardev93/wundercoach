class Crm::ContactTagsController < ApplicationController
  before_action :set_crm_contact_tag, only: %i(show edit update destroy)

  # GET /crm/contact_tags
  def index
    authorize_feature! 'contact_manager'
    # @contact_tags = Crm::ContactTag.all
    # @contact_tags = Contact tag.page(params[:page]).order('id ASC')
    @contact_tags = if params[:search]
      Crm::ContactTag.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Crm::ContactTag.page(params[:page]).order('name ASC')
    end
  end

  # GET /crm/contact_tags/1
  def show
    authorize_feature! 'contact_manager'
  end

  # GET /crm/contact_tags/new
  def new
    authorize_feature! 'contact_manager'
    @contact_tag = Crm::ContactTag.new
  end

  # GET /crm/contact_tags/1/edit
  def edit
    authorize_feature! 'contact_manager'
  end

  # POST /crm/contact_tags
  def create
    authorize_feature! 'contact_manager'
    @contact_tag = Crm::ContactTag.new(crm_contact_tag_params)
    if @contact_tag.save
      redirect_to crm_contact_tags_path, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /crm/contact_tags/1
  def update
    authorize_feature! 'contact_manager'
    if @contact_tag.update(crm_contact_tag_params)
      redirect_to crm_contact_tags_path, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /crm/contact_tags/1
  def destroy
    authorize_feature! 'contact_manager'
    @contact_tag.destroy
    redirect_to crm_contact_tags_url, notice: t(:delete_successful)
  end

  private

  def set_crm_contact_tag
    @contact_tag = Crm::ContactTag.find(params[:id])
  end

  def crm_contact_tag_params
    params.require(:crm_contact_tag).permit(:name, :account_id)
  end
end
