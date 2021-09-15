# Controller for PayPal Setup in settings area
class Account < ApplicationRecord
  module Paymentmethods
    # This Controller handles updating Sofort.com Payment-Data
    class PaypalController < ApplicationController
      layout 'account'
      def edit
        @form = Account::PaypalForm.new(@account)
      end

      def update
        result = Account::UpdatePaypal.call(params[:account_paypal], 'model' => @account)
        if result.success?
          redirect_to payment_path, notice: t(:paypal_com_integrated)
        else
          @form = result['contract.default']
          render 'edit'
        end
      end
    end
  end
end
