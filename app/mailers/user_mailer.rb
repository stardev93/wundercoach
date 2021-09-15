class UserMailer < WcoachMailer
  # UserMailer: User Activation and Password reset.
  # used in config/initializers/sorcery.rb
  # and other locations

  # email confirmation email to newly registered users
  # sent from app/controllers/users_controller.rb
  def activation_needed_email(user)
    @subject = 'Bitte bestätigen Sie Ihre E-Mail'
    @user = user
    @url = activate_url(user.activation_token, subdomain: @user.account.subdomain)

    mail(to: @user.email,
         subject: @subject)
  end

  # FIXME: We use this for both account generation and creating user from the backend
  # We need a different email for creating users!
  # sent from
  # app/concepts/account/operation/register.rb
  # app/concepts/user/operation/create.rb
  def internal_activation_needed_email(user)
    @subject = t(:internal_activation_needed_email_subject)
    @account = user.account
    @user = user
    @url = activate_url(user.activation_token, subdomain: @user.account.subdomain)

    mail(to: @user.email, subject: @subject)
  end

  def activation_success_email(user)
    @subject = 'Ihr Account wurde aktiviert. Willkommen bei Wundercoach'
    @user = user
    @url  = login_url
    mail(to: @user.email,
         subject: @subject)
  end

  def confirm_email(user)
    @subject = 'Please confirm your email'
    @user = user

    mail(to: @user.email,
         subject: @subject)
  end

  def reset_password_email(user)
    @user = user
    @subject = I18n.t(:reset_password_mail_subject)
    @url = edit_password_reset_url(user.reset_password_token)
    mail(to: user.email,
         subject: @subject)
  end

end
