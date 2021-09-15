class Billing::InvoiceDecorator < Billing::BusinessdocumentDecorator
  delegate_all

  def frozen?
    object.frozen?
  end

  def can_cancel?
    object.can_cancel?
  end

end
