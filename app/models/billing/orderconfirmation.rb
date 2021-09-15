module Billing
  class Orderconfirmation < Businessdocument

    def to_s
      I18n.t(:orderconfirmation_number) + ' ' + invoice_number.to_s
    end

    # def next_document_number
    #   false
    # end
    private

  end
end
