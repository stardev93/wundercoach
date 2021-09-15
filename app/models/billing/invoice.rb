module Billing
  class Invoice < Billing::Businessdocument

    # Validation
    validates :invoice_number, uniqueness: { scope: :account }, if: :invoice_number
    # validates_attachment :pdf, content_type: { content_type: 'application/pdf' }
    # validates :invoicestatus, :invoicetype, :paymentstatus, :address, presence: true
    validates :invoicestatus, :invoicetype, :paymentstatus, presence: true

    def to_s
      if invoice_number
        I18n.t(:"Billing::Invoice") + ' ' + invoice_number.to_s
      else
        I18n.t(:"Billing::Invoice") + ' (' + I18n.t(:draft) + ')'
      end
    end

    # change the paymentstatus with one click.
    # should work only for invoices, not for other object inheriting from businessdocument
    # works only if invoice is related to an order object (automatic invoices from checkout)
    # biggest flaw: no manual setting of paymentdate possible
    # ToDo: refine this.
    def change_paymentstatus(status)
      self.paymentstatus = status
      case status.key
      when 'paid'
        self.paymentdate = Date.today
        if self.order
          order.paid!
        end
      when 'open'
        if self.order
          if paymentmethod.key == 'vorkasse'
            order.waiting_for_payment!
          else
            order.confirmed!
          end
        end
      end
    end

    def recipient1
      # get the company or the firstname + lastname as recipient
      # address object holds address or invoice address
      if address
        address.company || address.fullname
      end
    end

    # cancel an invoice
    # returns the cancelled invoiced. needs handling in cancellation object
    def cancel
      # call the service InvoiceCancel
      return InvoiceCancel.new(self).perform
    end

    def due_date
      if read_attribute(:due_date)
        read_attribute(:due_date) || invoice_date + 14.days
      end
    end

    # can the object (i.e. invoice) be cancelled?
    # only invoices can be cancelled for now
    # ToDo: align this with invoice.frozen?
    def can_cancel?
      if frozen? && !self.get_successor
        # && invoicestatus && invoicestatus.key != "new"
        # if invoicestatus && invoicestatus.key != "new" && self.get_successor
        true
      else
        false
      end
    end

    # can object be deleted?
    # document must not be frozen and must not have a successor and is not marked as paid
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
