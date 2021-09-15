module BusinessdocumentHelper
  def payment_indicator(businessdocument)
    if businessdocument.cancelled?
      @class = 'btn-default'
      @text = "#{t(:cancelled)} #{businessdocument.get_successor}"
    elsif businessdocument.paid?
      @class = 'btn-success'
      @text = "#{t(:paid)} #{l businessdocument.paymentdate unless businessdocument.paymentdate.nil?}"
    elsif businessdocument.due?
      @class = 'btn-danger'
      @text = "#{t(:due)} #{l businessdocument.due_date}"
    else
      @class = 'btn-primary'
      @text = t(:open)
    end

    content_tag :a, class: "btn btn-xs #{@class}", role: "button" do
      if block_given?
        yield
      else
        @text
      end
    end
  end

  # displays a small icon with first letter of Document Type
  def document_type_indicator(businessdocument)

    @class = case businessdocument.type
    when "Billing::Quote" then "btn-info"
    when "Billing::Orderconfirmation" then "btn-warning"
    when "Billing::Invoice" then "btn-success"
    when "Billing::Cancellation" then "btn-default"
    else 'btn-default'
    end

    @bdoc_symbol = I18n::t(:"#{businessdocument.type.to_s}_symbol")

    content_tag :a, class: "btn btn-xs #{@class}", role: "button" do
      if block_given?
        yield
      else
        @bdoc_symbol
      end
    end
  end
end
