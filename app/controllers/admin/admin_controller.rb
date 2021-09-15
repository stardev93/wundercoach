class Admin::AdminController < ApplicationController
  skip_before_filter :set_tenant_and_account
  before_filter { authorize!(:manage, :backend) }

  layout 'backend'
end
