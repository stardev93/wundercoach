class EventbookingDecorator < Draper::Decorator
  delegate_all
  def context()
    {
      'account_id' => object.account_id,
      #'event' => object.event,
      'eventbookingstatus_id'  => object.eventbookingstatus_id,
      'early_booking_applies' => object.early_booking_applies,
      'booking_date' => object.booking_date,
      'additional_data' => object.additional_data,
      'accepts_crm' => object.accepts_crm,
      'address' => AddressDecorator.new(object.address).context,
      'billing_address' => AddressDecorator.new(object.address).context,
      'event' => Embedded::EventDecorator.new(object.event).context
    }
  end

  # decorate a pdf
  def certificate_pdf(pdftemplate)
    html = Liquid::Template.parse(pdftemplate.body_code).render(self.context)
    # tie components of pdf together
    html_options = ['eventbookings/pdf/certificate/certificate_pdf.html', layout: 'pdf_page.html', locals: { :@title => "#{object.address.firstname} #{object.address.lastname}", :@html => html, :@eventbooking => object, :@pdftemplate => pdftemplate }]
    generator = ::PdfGenerator.new(html_options, pdftemplate.pdf_options)
    generator.footer_html_options = ['eventbookings/pdf/certificate/footer.html', layout: 'pdf_page.html', locals: { :@eventbooking => self, :@pdftemplate => pdftemplate }]
    generator.header_html_options = ['eventbookings/pdf/certificate/header.html', layout: 'pdf_page.html', locals: { :@eventbooking => self, :@pdftemplate => pdftemplate, :@pdfname => I18n.t(:participantlist) }]
    generator.rendered_pdf
  end

  def certificate_pdf_filename
    "#{I18n.t(:certificate)}_#{object.address.lastname}_#{object.address.firstname}.pdf".downcase.tr!(" ", "_")
  end

  def booking_date
    if object.booking_date
      l object.booking_date.in_time_zone(object.account.get_time_zone), format: :short
    end
  end

  def booking_time
    unless object.booking_date.blank?
      object.booking_date.in_time_zone(object.account.get_time_zone).strftime('%H:%M') + ' ' + I18n.t('oclock').html_safe
    end
  end

  def info
    "#{object.firstname} #{object.lastname} #{I18n.t(:booking_date)} #{booking_date}"
  end

  private

end
