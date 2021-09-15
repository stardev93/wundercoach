module Sofort
  # Initializes Sofort.com transaction
  class StartTransaction < Transaction
    # Post Data to sofort.com, get an xml-response, and handle the response
    def run
      return unless @order.ready_for_transaction?
      @request.body = initialize_transaction_xml
      response = send_request
      handle_response response
      # We don't need validations and callbacks here, since we did that earlier
      @order.update_column(:sofort_id, @sofort_id)
      yield @payment_url
    end

    private

    # checks if availbable data has been fetched from psp response
    def success?
      @sofort_id.present? && @payment_url.present?
    end

    # Determine if we successfully got a response
    # process it, or log the error
    def handle_response(response)
      if response.code == "200"
        log response.body
        fetch_response_values Nokogiri::XML(response.body)
      else
        debug "Error while trying to query sofort.com: #{response.code}: #{response}"
      end
      success?
    end

    # returns xml for the initialization request
    def initialize_transaction_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.multipay do
          xml.amount @order.amount
          xml.sender do
            xml.holder @order.holder
            xml.country_code @order.country_code
          end
          xml.currency_code @order.currency
          xml.reasons do
            xml.reason @order.reason_for_payment
            xml.reason @order.creditor
          end
          xml.success_url @order.success_url
          xml.abort_url @order.abort_url
          xml.su
          xml.project_id @order.project_id
        end
      end
      builder.to_xml
    end

    # last step of intitiating a transaction, executed before redirecting
    # read xml, check for warnings/errors and get relevant values from response
    def fetch_response_values(xml)
      transaction = xml.xpath("/new_transaction")
      if transaction
        @sofort_id = transaction.xpath("//transaction").first.content
        @payment_url = transaction.xpath("//payment_url").first.content
        warnings = transaction.xpath("//warnings")
        handle_xml_warnings warnings unless warnings.empty?
      else
        handle_xml_errors xml
      end
    end

    def handle_xml_warnings(xml)
      debug "Warnings reported: #{xml}"
    end

    def handle_xml_errors(xml)
      debug "Errors reported: #{xml}"
    end
  end
end
