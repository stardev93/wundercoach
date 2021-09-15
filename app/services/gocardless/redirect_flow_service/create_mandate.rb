module Gocardless
  # Implements Gocardless' Redirect Flow for collecting a direct debit mandate
  module RedirectFlowService
    class CreateMandate < Gocardless::Order
      # queries gocardless for mandate
      # saves mandate, discards redirect_flow_id
      def run
        redirect_flow = @client.redirect_flows.complete(
          @order.gocardless_redirect_flow_id,
          params: { session_token: @order.session_token }
        )
        @order.update!({
          gocardless_mandate_id: redirect_flow.links.mandate,
          gocardless_redirect_flow_id: nil
        })
        yield
      end
    end
  end
end
