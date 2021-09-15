# offers users read only access to invoices
class AccountinvoicesController < ApplicationController
  before_action :set_accountinvoice, only: :pdf
  authorize_resource

  # GET /accountinvoices/1/pdf
  # Generate and show pdf
  def pdf
    # if there is no filename (invoice has not been generated) or the file is not present -> create it
    if @accountinvoice.pdf_file_name.blank? || !@accountinvoice.pdf.exists?
      @accountinvoice.create_pdf
      @accountinvoice.save!
    end
    # new_status = 'printed'
    # if @accountinvoice.accountinvoicestatus.key == 'sent'
    #   new_key = 'printed_and_sent'
    # end
    # @accountinvoice.accountinvoicestatus = Invoicestatus.find_by(key: new_status)
    # @accountinvoice.save!
    # raise @accountinvoice.pdf.url
    send_file(@accountinvoice.pdf.path, filename: @accountinvoice.pdf_file_name, type: 'application/pdf', disposition: 'inline')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_accountinvoice
    @accountinvoice = Accountinvoice.find(params[:id])
  end
end
