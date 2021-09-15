class Affiliate::AffiliateController < ApplicationController
  skip_before_filter :set_tenant_and_account
  before_filter { authorize!(:manage, :backend) }
end
