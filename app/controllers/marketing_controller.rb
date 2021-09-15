class MarketingController < ApplicationController
  before_action -> { require_feature("crm_functions") }
  authorize_resource class: false

  def index; end
end
