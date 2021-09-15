module Billing
  class Quote < Businessdocument

    def to_s
      I18n.t(:quote_number) + ' ' + invoice_number.to_s
    end

    # def next_document_number
    #   false
    # end

    private

  end
end
