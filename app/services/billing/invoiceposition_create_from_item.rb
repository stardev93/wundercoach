# Service for manually creating an invoiceposition from an event

class InvoicepositionCreateFromItem
  # initialize with businessdocument to create an new businessdocumentposition
  def initialize(businessdocument, item)
    @businessdocument = businessdocument.decorate
    @item = item.decorate
  end

  def perform
    # create the new invoiceposition
    if @item.shortdescription
      short_description = ActionView::Base.full_sanitizer.sanitize(@item.shortdescription)
    else
      short_description = ''
    end
    Billing::Businessdocumentposition.create({
      businessdocument: @businessdocument,
      name: @item.name,
      description: short_description,
      amount: 1,
      price: @item.price,
      vat: @item.vat,
      product: @item
    })
  end

end
