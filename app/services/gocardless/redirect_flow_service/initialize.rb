module Gocardless
  # Implements Gocardless' Redirect Flow for collecting a direct debit mandate
  module RedirectFlowService
    class Initialize < Gocardless::Order
      def run
        redirect_flow = @client.redirect_flows.create({
          params: {
            description: @order.description,
            session_token: @order.session_token,
            success_redirect_url: @order.success_redirect_url
          }
        })
        @order.update!(gocardless_redirect_flow_id: redirect_flow.id)
        yield redirect_flow.redirect_url
      end
    end
  end
end
