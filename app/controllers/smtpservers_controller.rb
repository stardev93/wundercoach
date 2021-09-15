class SmtpserversController < ApplicationController
  before_action :set_smtpserver, only: %i(show edit update destroy activate testconnection)

  # GET /smtpservers/1/activate
  def activate
    if @smtpserver.can_activate?
      @smtpserver.activate
      redirect_to smtpserversettings_path, notice: t(:smtpserver_activation_successful)
    else
      redirect_to smtpserversettingsedit_path(@smtpserver), notice: t(:smtpserver_activation_failed)
    end
  end

  # GET /smtpservers/1/test
  def testconnection
    #@dnssettings = @smtpserver.
    SmtpserverMailer.delay.smtpsendtest(@account, @smtpserver, current_user)
    redirect_to smtpserversettings_path, notice: t(:smtpserver_testmail_sent, recipient_email: current_user.email)
  end

  # GET /smtpservers
  def index
    # @smtpservers = Smtpserver.all
    # @smtpservers = Smtpserver.page(params[:page]).order('id ASC')
    @smtpservers = if params[:search]
      Smtpserver.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
    else
      Smtpserver.page(params[:page]).order('name ASC')
    end
  end

  # GET /smtpservers/1
  def show
  end

  # GET /smtpservers/new
  def new
    @smtpserver = Smtpserver.new
  end

  # GET /smtpservers/1/edit
  def edit
  end

  # POST /smtpservers
  def create
    @smtpserver = Smtpserver.new(smtpserver_params)
    if @smtpserver.save
      redirect_to @smtpserver, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /smtpservers/1
  def update
    result = Smtpserver::Update.call(smtpserver_params, 'model' => @smtpserver)
    if result.success?
    #if @smtpserver.update(smtpserver_params_new)
      redirect_to smtpserversettings_path, notice: t(:update_successful)
    else
      render template: "accounts/smtpserversettingsedit", layout: "account"
    end
  end

  # DELETE /smtpservers/1
  def destroy
    @smtpserver.destroy
    redirect_to smtpservers_url, notice: t(:delete_successful)
  end

  private

  def set_smtpserver
    @smtpserver = Smtpserver.find(params[:id])
  end

  def smtpserver_params
    params.require(:smtpserver).permit(:account_id, :name, :description, :server, :port, :ssl, :from_address, :from_name, :replyto_address, :username, :password, :authentication, :starttls, :openssl, :active)
  end
end
