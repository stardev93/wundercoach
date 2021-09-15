# Service for manually creating an invoiceposition from an event

class InvoicepositionCreateFromBundle
  # initialize with businessdocument to create an new businessdocumentposition
  def initialize(businessdocument, bundleevent)
    @businessdocument = businessdocument.decorate
    @bundleevent = bundleevent.decorate
  end

  def perform
    # create the new invoiceposition
    bundle_name = @bundleevent.name
    if @bundleevent.start_date
      bundle_name = bundle_name + ' ' + @bundleevent.start_date.to_s
    end

    if @bundleevent.shortdescription
      @shortdescription = ActionView::Base.full_sanitizer.sanitize(@bundleevent.shortdescription.html_safe)
    else
      @shortdescription = ''
    end

    # get subevents
    @subevents = @bundleevent.subevents.by_date
    @subevents.each do |subevent|
      event_name = subevent.subevent.decorate.name

      if subevent.subevent.start_date && subevent.subevent.end_date
        date_range = subevent.subevent.decorate.start_date + '-' + subevent.subevent.decorate.end_date
      else
        date_range = ''
      end
      event_name = date_range + ' ' + event_name
      
      @shortdescription = @shortdescription + "\r\n"
      @shortdescription = @shortdescription + event_name.html_safe
    end

    Billing::Businessdocumentposition.create({
      businessdocument: @businessdocument,
      name: bundle_name,
      description: @shortdescription,
      amount: 1,
      price: @bundleevent.price,
      vat: @bundleevent.vat,
      product: @bundleevent
    })
  end

end
