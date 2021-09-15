# handles account-registration-process and creation of stripe-customers
class RegisterController < ApplicationController
  skip_before_filter :require_login, :set_tenant_and_account
  layout 'extern'

  invisible_captcha only: [:create]

  # GET /register/new
  def new
    if params[:token]
      @affiliate = Affiliate.find_by_token(params[:token])
      flash.now[:notice] =
        if @affiliate
          t(:affiliate_participation, affiliate: @affiliate.name)
        else
          t(:invalid_token)
        end
    end
    @form = Account::RegistrationForm.new(Account.new(creator: User.new))
  end

  # Account creation Step 1: Creation of a new account with free paymentplan when users sign up thru /register/new
  # POST /register
  # creates an account and a first user for the account
  def create
    # check for affiliate token to assign account to affiliate
    affiliate = params[:affiliate_token] ? Affiliate.find_by_token(params[:affiliate_token]) : nil
    # The "free" parameter is only used by spam bots
    return redirect_to login_path if params[:account][:free].present?
    # Trailblazer action
    result = Account::Register.call(params[:account], 'affiliate' => affiliate)
    if result.success?
      redirect_to register_success_path
    else
      @form = result['contract.default']
      render action: 'new'
    end
  end

  def success; end

  def privacy
  end

  def terms
  end

end
