# adds utility methods and global filters, sets tenant
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale, :require_login, :set_tenant_and_account
  set_current_tenant_through_filter # calls set_tenant_and_account

  helper_method :get_browser_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :forbidden }
      format.html { redirect_to main_app.root_url, alert: exception.message }
    end
  end

  # If customers try to use a feature they cannot access, we offer them
  # to upgrade their plan, using this rescue
  rescue_from FeatureCheck::FeatureNotIncluded do |_exception|
    respond_to do |format|
      format.json { render nothing: true, status: :forbidden }
      # we currently have html, pdf and csv covered by using format.all
      format.all { redirect_to :back, flash: { feature_check: I18n.t(:not_in_plan_text) } }
    end
  end

  # get the browsers timezone for
  # taken from https://github.com/iansinnott/jstz (Timezone detection for JavaScript)
  # using gem gem 'rails-assets-jsTimezoneDetect'
  def get_browser_time_zone
    browser_tz = ActiveSupport::TimeZone.find_tzinfo(cookies[:browser_time_zone])
    ActiveSupport::TimeZone.all.find { |zone| zone.tzinfo == browser_tz } || Time.zone

    rescue TZInfo::UnknownTimezone, TZInfo::InvalidTimezoneIdentifier
    Time.zone
  end

  protected

  # Finds feature by key and raises FeatureCheck::FeatureNotAvailable if it cannot be accessed
  # use this instead of authorize! to get special FeatureCheck functionality
  def authorize_feature!(key)
    feature = Feature.find_by(key: key)
    authorize! :access, feature
  rescue CanCan::AccessDenied => e
    raise FeatureCheck::FeatureNotIncluded, e.message
  end

  def require_feature(key)
    @required_feature = Feature.find_by(key: key)
  end

  def redirect_to_back(default = root_url, options = {})
    if request.env['HTTP_REFERER'].present? && request.env['HTTP_REFERER'] != request.env['REQUEST_URI']
      redirect_to :back, options
    else
      redirect_to default, options
    end
  end

  private

  def set_tenant_and_account
    if logged_in?
      @account = current_user.account
      # force correct subdomain
      if @account.subdomain != request.subdomain
        redirect_to subdomain: @account.subdomain
      end
    else
      @account = Account.find_by subdomain: request.subdomain
    end
    if @account
      set_current_tenant @account unless is_a?(RailsAdmin::MainController)
    elsif request.subdomain != EXTERNAL_SUBDOMAIN
      # User is not logged in and has not entered a (valid) subdomain
      # Let's assume he wants to sign up/sign in!
      redirect_to root_url(subdomain: EXTERNAL_SUBDOMAIN)
    end
  end

  def not_authenticated
    redirect_to main_app.login_url
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
