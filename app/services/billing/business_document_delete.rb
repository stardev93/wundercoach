# Service for cancelling an invoice
class BusinessdocumentDelete

  # initialize with order object to create an new invoice
  def initialize(businessdocument)
    @businessdocument = businessdocument
  end

  def perform
    # businessdocumentpositions = @businessdocument.businessdocumentpositions.delete_all
    @businessdocument.businessdocumentpositions.each do |businessdocumentposition|
      businessdocumentposition.destroy!
    end
    @businessdocument.destroy!
  end
end
