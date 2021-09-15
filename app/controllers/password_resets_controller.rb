# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :set_tenant_and_account
  skip_authorization_check
  layout 'extern'
  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create
    @user = User.find_by_email(params[:email])

    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    @user&.deliver_reset_password_instructions!

    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
    redirect_to(login_path, notice: I18n.t(:instructions_have_been_sent_to_your_email))
  end

  # This is the reset password form.
  def edit
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
    @form = User::PasswordForm.new(@user)
  end

  # This action fires when the user has sent the reset password form.
  def update
    @user = User.find(params[:id])

    @form = User::PasswordForm.new(@user)
    if @form.validate(params[:user])
      @form.save do |attributes|
        @user.change_password!(attributes[:password])
      end
      #auto_login @user
      redirect_to(root_path, notice: I18n.t(:password_reset))
    else
      render action: 'edit'
    end
  end
end
