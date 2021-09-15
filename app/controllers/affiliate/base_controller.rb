class Affiliate < ActiveRecord::Base
  # Affiliate Dashboard
  class BaseController < ApplicationController
    skip_before_filter :set_tenant_and_account
    before_filter :set_affiliate

    private

    def set_affiliate
      @affiliate = current_user.account.affiliate
    end
  end
end
