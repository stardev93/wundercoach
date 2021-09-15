require 'reform/form/coercion'
# Form for updating and validating the account's sofort.com access data
class Address < ActiveRecord::Base
  # like address form, but can be turned off via the different_billing_address flag
  class BillingAddressForm < AddressForm
    feature Coercion
    property :different_billing_address, virtual: true, type: Types::Form::Bool
  end
end
