class Crm::ContactAddressDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  CONTACT_ADDRESS_TYPES_HASH = {
                                  " " => " ",
                                  I18n.t(:billing_address) => "billing_address",
                                  I18n.t(:delivery_address) => "delivery_address",
                                  I18n.t(:other_address) => "other_address"
                                }.freeze
  def address_type
    I18n.t(:"#{object.address_type}") if object.address_type.present?
  end
end
