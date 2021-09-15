class Crm::ContactsController < ApplicationController
  before_action :set_contact, only: %i(show edit update destroy)

  # GET /contacts
  def index
    authorize_feature! 'contact_manager'

    session[:q] ||= Hash.new
    session[:q]['name_or_name2_or_firstname_or_lastname_or_contact_no_or_account_receivable_no_or_contact_addresses_street_or_contact_details_detail_value_cont'] ||= ''
    session[:q]['type_eq'] ||= ''
    session[:q]['contact_tags_id_eq'] ||= ''

    if params['filter'] == 'reset'
      session[:q] = Hash.new
      session[:q]['name_or_name2_or_firstname_or_lastname_or_contact_no_or_account_receivable_no_or_contact_addresses_street_or_contact_details_detail_value_cont'] = ''
      session[:q]['type_eq'] = ''
      session[:q]['contact_tags_id_eq'] = ''
    end
    # merge freshly send params with existing session, adding up filter parameters until session is cleared
    if params[:q]
      session[:q] = session[:q].merge(params[:q])
    end

    @q = Crm::Contact.ransack(session[:q])
    @q.sorts = ['name ASC'] if @q.sorts.empty?
    @contacts = @q.result(distinct: true).with_addresses.with_tags
    @companies = Crm::ContactDecorator.decorate_collection(@contacts.where(type: 'Company'))
    @persons = Crm::ContactDecorator.decorate_collection(@contacts.where(type: 'Person'))

    respond_to do |format|
      format.html {
          @contacts = @contacts.page(params[:page])
      }
      format.xlsx {
        authorize_feature! 'csv_export'


        if params[:t] == 'companies'
          response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:companies)}-#{Date.today}.xlsx"
          render :template => "crm/contacts/companies"
        elsif params[:t] == 'persons'
          response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:persons)}-#{Date.today}.xlsx"
          render :template => "crm/contacts/persons"
        else
          response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:companies)}-#{I18n.t(:persons)}-#{Date.today}.xlsx"
          render :template => "crm/contacts/contacts"
        end
      }
      # format.csv do
      #   authorize_feature! 'csv_export'
      #   send_data(@events.csv_list.encode("UTF-8"), :type => 'text/csv; charset=iso8859-1; header=present', filename: "#{I18n.t(:events)}-#{Date.today}.csv")
      # end

    end
  end

  # GET /contacts/1
  def show
    authorize_feature! 'contact_manager'
    @businessdocuments = @contact.businessdocuments.page(params[:businessdocumentspage])
    @invoices = @contact.invoices.page(params[:businessdocumentspage])
    @quotes = @contact.quotes.page(params[:businessdocumentspage])
  end

  # GET /contacts/new
  def new
    authorize_feature! 'contact_manager'
    @contact = Crm::Contact.new
    if params[:contact_id]
      @company = Crm::Contact.find(params[:contact_id])
      @contact.company = @company
    end
    if params[:type]
      @contact.type = params[:type]
    else
      @contact.type = "Company"
    end
  end

  # GET /contacts/1/edit
  def edit
    authorize_feature! 'contact_manager'
  end

  # POST /contacts
  def create
    authorize_feature! 'contact_manager'
    @contact = Crm::Contact.new(contact_params)
    if @contact.save
      redirect_to @contact, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /contacts/1
  def update
    authorize_feature! 'contact_manager'
    if @contact.update(contact_params)
      redirect_to @contact, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /contacts/1
  def destroy
    authorize_feature! 'contact_manager'
    @contact.destroy
    redirect_to crm_contacts_path, notice: t(:delete_successful)
  end

  private

  def set_contact
    @contact = Crm::Contact.find(params[:id])
  end

  def contact_params
    params.require(:crm_contact).permit(:account_id, :type, :name, :name2, :lastname, :firstname, :gender, :vat_id, :register, :register_code, :contact_no, :account_receivable_no, :contact_type, :comments, :contact_id, contact_tag_ids: [],)
  end
end
