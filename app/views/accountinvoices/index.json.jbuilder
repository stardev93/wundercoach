json.array!(@accountinvoices) do |accountinvoice|
  json.extract! accountinvoice, :id, :account_id, :booking_id, :invoice_date, :email_to, :invoice_number, :payment_date, :recipient_name_1, :recipient_name_2, :street, :street_no, :zip, :city, :country, :invoicetype_id, :invoicestatus_id, :successor, :predecessor, :pdf_file_name, :pdf_content_type, :pdf_file_size, :pdf_updated_at
  json.url accountinvoice_url(accountinvoice, format: :json)
end
