# handles crud operations as well as user confirmation and (re)setting password
class UsersController < ApplicationController
  skip_before_filter :require_login, only: :activate
  before_action :set_user, only: %i(show edit update destroy assignrole revokerole invite toggle resetpassword participant changepassword updatepassword activateinternal mutemessage)
  authorize_resource

  def mutemessages
    respond_to do |format|
      format.json do
        if (@user = User.find(params[:id]))
          @user.mutemessages
        end
        head :ok
      end
    end

  end

  def mutemessage
    @user.usermessages.where('user_id = ? and message_id = ?', @user.id, params[:message_id]).delete_all
    redirect_to request.referrer
  end

  def messages
    @messages = Message.paginate(page: params[:page]).includes(:usermessages).showing
    if params[:message]
      @message_id = params[:message]
    else
      @message_id = nil
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      auto_login(@user)
      redirect_to root_path
    else
      not_authenticated
    end
  end

  def activateinternal
    @user.activate!
    redirect_to users_path, notice: t(:internal_activation_successful)
  end

  # GET /users/confirm
  def confirm
    @account = Account.find(current_user.account_id)
    UserMailer.delay.activation_needed_email(current_user)
    redirect_to welcome_path
  end

  # GET /users
  def index
    @users = User.internal.by_name.page(params[:page])
    @users = @users.search(params[:search]) if params[:search]
  end

  # GET /users
  def participants
    @users = User.participants.page(params[:page])
    @users = @users.search(params[:search]) if params[:search]
  end

  # GET /users/1
  def show
    redirect_to edit_user_path(@user), notice: t(:user_incomplete_notice) unless @user.complete?
  end

  # GET /users/1
  def participant; end

  # GET /users/new
  def new
    @form = UserForm.new(User.new)
  end

  # GET /users/1/edit
  def edit
    @form = UserForm.new(@user)
  end

  # GET /users/1/changepassword
  def changepassword
    @form = User::PasswordForm.new(@user)
  end

  # POST /users
  def create
    result = User::Create.call(params[:user])
    if result.success?
      redirect_to users_path, notice: t(:user_created_confirm_email)
    else
      @form = result['contract.default']
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    result = User::Update.call(params[:user], 'model' => @user)
    if result.success?
      redirect_to users_path, notice: t(:update_successful)
    else
      @form = result['contract.default']
      render action: 'edit'
    end
  end

  # PATCH/PUT /users/1
  def updatepassword
    is_new_user = @user.crypted_password.blank?
    result = User::UpdatePassword.call(params[:user], 'model' => @user)
    if result.success?
      if is_new_user
        redirect_to root_path, notice: t(:password_successfully_set)
      else
        redirect_to @user, notice: I18n.t(:password_reset)
      end
    else
      @form = result['contract.default']
      render action: 'changepassword'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_path, notice: t(:delete_successful)
  end

  # resetpassword/users/1
  def resetpassword
    # send an email to the user with instructions on how to reset their password (a url with a random token)
    @user.delay.deliver_reset_password_instructions! if @user
    redirect_to users_path, notice: t(:password_instructions_sent, email: @user.email)
  end

  # GET /users/1/assignrole/role_id
  def assignrole
    @role = Role.find(params[:role_id])
    @user.roles << @role unless @user.roles.exists?(@role)
    redirect_to @user, notice: t(:role_was_successfully_assigned)
  end

  # GET /users/1/revokerole
  def revokerole
    @userrole = Userrole.find(params[:role_id])
    @user.removerole(@userrole)
    redirect_to @user, notice: t(:role_was_successfully_revoked)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end
end
