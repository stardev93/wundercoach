# Create a new Contact from businessdocument, closely related to ContactCreateFromEventbooking
# ContactCreateFromBusinessdocument.new(@businessdocument).perform
class ContactCreateFromBusinessdocument

  # initialize with invoice object to send an invoice
  def initialize(businessdocument)
    @businessdocument = businessdocument
  end

  def perform
    @contact = Crm::Contact.new
    @contact.account = @businessdocument.account

    # do we have an address object attached? (created from web order)
    if @businessdocument.address
      if @businessdocument.address.company.blank?
        @contact.type = "Person"
      else
        @contact.type = "Company"
      end
      @contact.lastname = @businessdocument.address.lastname
      @contact.firstname = @businessdocument.address.firstname
      @contact.name = @businessdocument.address.company
      @contact.gender = @businessdocument.address.gender

      @contact.add_full_name if @contact.type == 'Person'
    else
      @contact.type = "Company"
      @contact.name = @businessdocument.recipient1.to_s
      @contact.name2 = @businessdocument.recipient2.to_s

      @contact.firstname = @businessdocument.recipient_name1.to_s
      @contact.lastname = @businessdocument.recipient_name2.to_s
    end
    @contact.save!

    # create normal address
    @contact_address = Crm::ContactAddress.new
    @contact_address.contact = @contact
    @contact_address.street = @businessdocument.recipient_street
    @contact_address.zip = @businessdocument.recipient_zip
    @contact_address.city = @businessdocument.recipient_city
    @contact_address.country = @businessdocument.recipient_country
    @contact_address.address_type = 'billing_address'
    @contact_address.save!

    # create contact_details
    if @businessdocument.recipient_email
      @contact_detail = Crm::ContactDetail.new
      @contact_detail.contact = @contact
      @contact_detail.detail_value = @businessdocument.recipient_email
      @contact_detail.detail_type = 'email'
      @contact_detail.save!
    end

    @businessdocument.contact = @contact
    @businessdocument.save!

    return @contact
  end

  private

end
