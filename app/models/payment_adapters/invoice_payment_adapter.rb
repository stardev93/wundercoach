# Handles Payment via Invoice
class InvoicePaymentAdapter < PaymentAdapter
  after_initialize :initialize_payment_info

  def self.model_name
    PaymentAdapter.model_name
  end

  # no charging is required for payment method invoice.
  def charge!(cents, idempotency_key)
    # we are not charging anything - customer pays via bank transfer
    { paymentmethod: payment_info }
  end

  private

  def initialize_payment_info
    self.payment_info = I18n.t(:invoice_payment_adapter_please_transfer_money)
  end
end
