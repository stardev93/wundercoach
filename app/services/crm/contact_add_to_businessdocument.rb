# Add a new Contact from eventboookingBusinessdocuments
# ContactCreateFromEventbooking.new(@eventbooking).perform
class ContactAddToBusinessdocument

  # initialize with invoice object to send an invoice
  def initialize(eventbooking)
    @eventbooking = eventbooking
  end

  def perform

    @eventbooking.order.businessdocuments.each do |businessdocument|
      businessdocument.contact = @eventbooking.contact
      businessdocument.save!
    end

    return @eventbooking
  end

  private

end
