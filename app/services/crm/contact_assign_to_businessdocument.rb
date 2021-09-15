# Create a new Contact from businessdocument, closely related to ContactCreateFromEventbooking
# ContactCreateFromBusinessdocument.new(@businessdocument).perform
class ContactAssignToBusinessdocument

  # initialize with invoice object to send an invoice
  def initialize(businessdocument, contact)
    @businessdocument = businessdocument
    @contact = contact
  end

  def perform
    @businessdocument.contact = @contact
    #contact_address_id
    @businessdocument.save!

    return @contact
  end

  private

end
