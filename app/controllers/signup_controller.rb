class SignupController < ApplicationController
  skip_before_action :require_login, only: %i(index error redirect new_request not_found)
  before_action :set_event, only: %i(redirect new_request)
  before_action :set_filters, only: :index
  skip_before_action :set_tenant_and_account, only: :not_found
  skip_authorization_check

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to signup_index_path, alert: exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do |_e|
    redirect_to signup_index_path, notice: t(:event_not_found)
  end

  def redirect; end

  def new_request
    authorize! :access, Feature.find_by(key: 'backend_individual_appointments')
    @request = Request.new(event: @event)
    render 'signup/requests/new'
  end

  def index
    @events = Event.with_includes.by_start_date.public_events.online_events.filter(@filters).distinct.page(params[:page])
    @individual_events = IndividualEvent.online.filter(@filters).distinct.page(params[:page])
    #@bundles = Bundle.online.page(params[:page])
    render 'index', layout: 'signup_full_width'
  end

  def error; end

  def not_found
    @account = Account.find_by(subdomain: request.subdomain)
    if @account.nil?
      render 'not_found', layout: 'signup_full_width'
    else
      redirect_to signup_index_path(locale: I18n.locale)
    end
  end

  private

  def set_filters
    if params[:clear]
      session[:event_filter] = nil
    elsif params[:event]
      session[:event_filter] = search_params
    end
    @filters = session[:event_filter] || {}
  end

  # This overrides the filter from ApplicationController
  def set_tenant_and_account
    @account = Account.find_by(subdomain: request.subdomain)
    if @account.nil?
      redirect_to signup_account_not_found_url(subdomain: EXTERNAL_SUBDOMAIN)
    else
      set_current_tenant @account
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to signup_index_path, notice: t(:event_not_found)
  end

  # Only allow a trusted parameter "white list" through.
  def search_params
    params.require(:event).permit(:search, :start_date, :end_date, search_by_tags: [])
  end
end
