# Handles login and logout
class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i(new create)
  # skip_before_action :set_tenant_and_account, only: :create
  skip_authorization_check
  layout 'extern'

  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user.nil?
      flash.now[:notice] = t('email_or_password_invalid')
      render :new
    elsif user.account.nil?
      # the account can be nil if it was soft deleted
      redirect_to root_url(subdomain: EXTERNAL_SUBDOMAIN), notice: t('account.deleted')
    elsif user.activated?
      attempt_login(user)
    else
      flash.now[:notice] = t('internal_activation_needed')
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_url(subdomain: EXTERNAL_SUBDOMAIN), notice: t(:logged_out)
  end

  private

  def attempt_login(user)
    if login(params[:email], params[:password])
      redirect_to(user.has_role?('affiliate') ? affiliate_dashboard_url(subdomain: user.account.subdomain) : root_url(subdomain: user.account.subdomain))
    else
      flash.now[:alert] = t('email_or_password_invalid')
      render :new
    end
  end
end
