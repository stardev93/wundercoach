# creates a Paymentterm for each Paymentmethod per Account.
# Paymentmethod is not ActsAsTenant, as it reflects the available paymentmethods in the system
# Paymentterm is ActsAsTenant and gives each account the ability to have its own description
class AccountSetupPaymenterms

  # initialize with invoice object to send an invoice
  def initialize(account)
    @account = account
  end

  def perform
    Paymentmethod.find_each do |paymentmethod|

      Paymentterm.create(
        {
          account_id: @account.id,
          paymentmethod_id: paymentmethod.id,
          name: paymentmethod.name,
          context: 'checkout',
          description: paymentmethod.comment,
          locale: 'de'
        }
      )
    end
  end

  # create a new paymentterm entry for @account for paymentmethod
  def add_paymentterm(paymentmethod)
    @paymentmethod = paymentmethod
    @paymentterm = Paymentterm.find_by(account: @account, paymentmethod: @paymentmethod)

    unless @paymentterm

      I18n.locale = :de
      @paymentterm = Paymentterm.create(
        {
          account_id: @account.id,
          paymentmethod_id: @paymentmethod.id,
          name: @paymentmethod.name,
          context: 'checkout',
          description: @paymentmethod.comment,
          locale: 'de'
        }
      )
      I18n.locale = :en
      @paymentterm.name = @paymentmethod.name
      @paymentterm.description = @paymentmethod.comment
      @paymentterm.save
      return @paymentterm
    else
      return @paymentterm
    end
  end
end
