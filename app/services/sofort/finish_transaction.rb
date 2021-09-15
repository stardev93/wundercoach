module Sofort
  class FinishTransaction < Transaction
    def run
      @request.body = build_status_request_body
      response = send_request
      log response.body
      xml = Nokogiri::XML(response.body)
      # if transaction is missing, this means that the transaction has not been
      # completed yet
      @time = xml.xpath("//time").first.content
      @complete = !xml.xpath("//transaction").empty?
      yield if @complete
    end

    private

    # xml for querying transaction status
    def build_status_request_body
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.transaction_request("version" => "2") do
          xml.transaction @order.sofort_id
        end
      end
      builder.to_xml
    end
  end
end
