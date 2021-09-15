class GocardlessPaymentAdapter < PaymentAdapter
  def self.model_name
    PaymentAdapter.model_name
  end

  after_initialize :load_gc_client

  # charges a billing period, returns payment id
  # can be given an idempotency_key to prevent charging twice
  def charge!(cents, idempotency_key)
    payment_data = {
      params: {
        amount: cents,
        currency: 'EUR',
        links: {
          mandate: gocardless_mandate_id
        }
      },
      headers: { 'Idempotency-Key' => idempotency_key }
    }
    payment = @client.payments.create(payment_data)
    { gocardless_payment_id: payment.id, paymentmethod: payment_info }
  end

  # Redirect FLow:
  # 1) We redirect the customer to gocardless, where she enters her IBAN etc.
  # 2) Gocardless creates a token and sends the customer back
  # 3) we use the token to create the mandate

  # initiates the redirect_flow (Step 1 of the redirect_flow)
  def create_redirect_flow(session_token, success_redirect_url)
    @redirect_flow = @client.redirect_flows.create(
      params: {
        description: 'Wundercoach Payment',
        session_token: session_token,
        success_redirect_url: success_redirect_url
      }
    )
  end

  # completes the redirect_flow, saves mandate id (Step 3 of the redirect_flow)
  def complete_redirect_flow!(session_token, redirect_flow_id)
    @redirect_flow = @client.redirect_flows.complete(
      redirect_flow_id,
      params: { session_token: session_token }
    )
    self.gocardless_mandate_id = @redirect_flow.links.mandate
    save!
    update_payment_info(@redirect_flow.links.customer_bank_account)
  end

  # exposes the redirect_flow's id
  def redirect_flow_id
    @redirect_flow.id
  end

  # exposes the redirect_flow's url
  def redirect_flow_url
    @redirect_flow.redirect_url
  end

  private

  def update_payment_info(bank_account_id)
    bank_account = @client.customer_bank_accounts.get(bank_account_id)
    update! payment_info: "······#{bank_account.account_number_ending} #{bank_account.bank_name}"
  end

  # creates a GoCardlessPro::Client, which communicates with the GC-API
  def load_gc_client
    @client = GoCardlessPro::Client.new({
      access_token: ENV['gocardless_access_token'],
      environment: ENV['gocardless_environment'].to_sym
    })
  end
end
