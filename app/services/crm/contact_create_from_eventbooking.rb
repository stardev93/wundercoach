# Create a new Contact from eventboooking, closely related to ContactCreateFromBusinessdocument
# ContactCreateFromEventbooking.new(@eventbooking).perform
class ContactCreateFromEventbooking

  # initialize with invoice object to send an invoice
  def initialize(eventbooking)
    @eventbooking = eventbooking
  end

  def perform
    @contact = Crm::Contact.new
    @contact.account = @eventbooking.account

    if @eventbooking.address.company.blank?
      @contact.type = "Person"
    else
      @contact.type = "Company"
    end

    @contact.lastname = @eventbooking.address.lastname
    @contact.firstname = @eventbooking.address.firstname
    @contact.name = @eventbooking.address.company
    @contact.gender = @eventbooking.address.gender

    @contact.add_full_name if @contact.type == 'Person'
    @contact.save!

    # create normal address
    @contact_address = Crm::ContactAddress.new
    @contact_address.contact = @contact
    @contact_address.street = @eventbooking.address.street
    @contact_address.zip = @eventbooking.address.zip
    @contact_address.city = @eventbooking.address.city
    @contact_address.country = @eventbooking.address.country
    @contact_address.address_type = 'delivery_address'
    @contact_address.save!

    # create normal address
    if @eventbooking.billing_address
      @contact_address = Crm::ContactAddress.new
      @contact_address.contact = @contact
      @contact_address.street = @eventbooking.billing_address.street
      @contact_address.zip = @eventbooking.billing_address.zip
      @contact_address.city = @eventbooking.billing_address.city
      @contact_address.country = @eventbooking.billing_address.country
      @contact_address.address_type = 'billing_address'
      @contact_address.save!
    end

    # create contact_details
    if @eventbooking.address.telephone
      @contact_detail = Crm::ContactDetail.new
      @contact_detail.contact = @contact
      @contact_detail.detail_value = @eventbooking.address.telephone
      @contact_detail.detail_type = 'private_phone'
      @contact_detail.save!
    end
    # create contact_details
    if @eventbooking.billing_address && @eventbooking.billing_address.telephone && @eventbooking.billing_address.telephone != @eventbooking.address.telephone
      @contact_detail = Crm::ContactDetail.new
      @contact_detail.contact = @contact
      @contact_detail.detail_value = @eventbooking.billing_address.telephone
      @contact_detail.detail_type = 'work_phone'
      @contact_detail.save!
    end
    # create contact_details
    if @eventbooking.address.email
      @contact_detail = Crm::ContactDetail.new
      @contact_detail.contact = @contact
      @contact_detail.detail_value = @eventbooking.address.email
      @contact_detail.detail_type = 'email'
      @contact_detail.save!
    end
    # create contact_details
    if @eventbooking.billing_address && @eventbooking.billing_address.email && @eventbooking.billing_address.email != @eventbooking.address.email
      @contact_detail = Crm::ContactDetail.new
      @contact_detail.contact = @contact
      @contact_detail.detail_value = @eventbooking.billing_address.email
      @contact_detail.detail_type = 'email'
      @contact_detail.save!
    end

    @eventbooking.contact = @contact
    @eventbooking.save!

    return @contact
  end

  private

end
