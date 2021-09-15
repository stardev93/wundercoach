require Rails.root.join('app', 'concepts', 'address', 'contracts', 'address_form.rb')
require Rails.root.join('app', 'concepts', 'address', 'contracts', 'billing_address_form.rb')
class Order < ActiveRecord::Base
  # Order Create form, only for creating orders from the backend
  class CreateForm < Reform::Form
    property :paymentmethod_id
    property :product

    property :address, form: Address::AddressForm, prepopulator: ->(*) { self.address ||= Address.new }, populate_if_empty: ->(*) { Address.new }
    property :billing_address,
             form: Address::BillingAddressForm,
             prepopulator: ->(*) { self.billing_address ||= Address.new },
             populate_if_empty: ->(*) { Address.new },
             skip_if: ->(fragment, *) { fragment[:doc]['billing_address']['different_billing_address'] == '0' }

    validates :paymentmethod_id, :product, presence: true
  end
end
