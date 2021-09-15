module Billing
  class Cancellation < Businessdocument

    def to_s
      I18n.t(:cancellation_number) + ' ' + invoice_number.to_s
    end

    # cancellations can not be duplicated
    # they can be generated from invoices only
    def can_duplicate?
      false
    end

    def can_cancel?
      false
    end

    # can object be deleted?
    # cancellation must not be frozen and must not have a successor and is not marked as paid
    def can_delete?
      if !frozen? && !self.get_successor && !paid?
        true
      else
        false
      end
    end

    private

  end
end
