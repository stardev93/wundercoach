class Account < ApplicationRecord
  module Paymentmethods
    # This Controller handles updating Sofort.com Payment-Data
    class SofortController < ApplicationController
      layout 'account'
      def edit
        @form = Account::SofortForm.new(@account)
      end

      def update
        result = Account::UpdateSofort.call(params[:account_sofort], 'model' => @account)
        if result.success?
          redirect_to payment_path, notice: t(:sofort_com_integrated)
        else
          @form = result['contract.default']
          render 'edit'
        end
      end
    end
  end
end
