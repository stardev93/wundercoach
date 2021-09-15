class Accountinvoiceposition < ActiveRecord::Base
  acts_as_list scope: :accountinvoice

  belongs_to :accountinvoice
  belongs_to :paymentplan
  belongs_to :billing_period

  def create_new(accountinvoice, billing_period)
    accountinvoiceposition = Accountinvoiceposition.new
    accountinvoiceposition.accountinvoice = accountinvoice
    accountinvoiceposition.billing_period = billing_period
    accountinvoiceposition.start_date = billing_period.start_date
    accountinvoiceposition.end_date = billing_period.end_date

    # original paymentplan reference
    accountinvoiceposition.paymentplan_id = billing_period.booking.paymentplan
    accountinvoiceposition.paymentplan_name = billing_period.booking.paymentplan.name
    accountinvoiceposition.paymentplan_cycle = billing_period.booking.paymentplan.cycle
    accountinvoiceposition.paymentplan_amount = 1.to_f
    accountinvoiceposition.paymentplan_price = billing_period.price.to_f

    accountinvoiceposition.amount = 1.to_f
    # customer in germany => german tax calculation
    if accountinvoice.account.is_de?
      # gross price is price including vat
      accountinvoiceposition.gross_price = billing_period.price.to_f
      # net price is price excluding vat
      accountinvoiceposition.net_price = (billing_period.price.to_f / (1 + accountinvoice.get_vat.value.to_f)).round(0)
      # vat percentage applicable
      accountinvoiceposition.vat = accountinvoice.get_vat.value.to_f
      # vat amount as difference between gross and net price
      accountinvoiceposition.vat_sum = (accountinvoiceposition.gross_price - accountinvoiceposition.net_price)

    # customer in eu, but not germany
    # customer somewhere in the rest of the world
    # BugFix: no elsif here - not only eu_ext countries
    # elsif accountinvoice.account.is_eu_ext?
    else
      # gross price is price excluding local german vat
      accountinvoiceposition.gross_price = billing_period.price.to_f
      # net price is gross_price excluding local german vat
      accountinvoiceposition.net_price = billing_period.price.to_f
      # vat percentage applicable, should be 0 here
      accountinvoiceposition.vat = accountinvoice.get_vat.value.to_f
      # vat amount as difference between gross and net price, should be 0 here
      accountinvoiceposition.vat_sum = (accountinvoiceposition.gross_price - accountinvoiceposition.net_price)

    end
    accountinvoiceposition.save

    accountinvoiceposition
  end
end
