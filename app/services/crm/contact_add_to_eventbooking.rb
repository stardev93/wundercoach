# Add a Contact from Businessdocument to eventbooking
# ContactAddToEventbooking.new(@businessdocument).perform
class ContactAddToEventbooking

  # initialize with invoice object to send an invoice
  def initialize(businessdocument)
    @businessdocument = businessdocument
  end

  def perform
    # do we have an order object assigned?
    # change this later - businessdocuments must not carry order objects, this will go to businessdocumentpositions and new object type insted of order
    if @businessdocument.order
      # get the eventbookings
      @businessdocument.order.eventbookings.each do |eventbooking|
        eventbooking.contact = @businessdocument.contact if @businessdocument.contact
        eventbooking.save!
      end
    end
    # do the same for businessdocumentpositions
    @businessdocument.businessdocumentpositions.each do |businessdocumentposition|
      # do we have an order assigned?
      if businessdocumentposition.order
        businessdocumentposition.order.eventbookings.each do |eventbooking|
          eventbooking.contact = @businessdocument.contact if @businessdocument.contact
          eventbooking.save!
        end
      end
    end
    return @businessdocument
  end

  private

end
