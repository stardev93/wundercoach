# Decorate the Paymentmethod
# Returns comment from associated Paymentterm
class PaymentmethodDecorator < Draper::Decorator
  delegate_all

  # gets the comment from paymentterm.description, if it exists for tenant.
  def comment
    if object.paymentterm && object.paymentterm.description
      object.paymentterm.description
    else
      object.comment
    end
  end

end
