module Signup
  # Starts Signup for a bundle
  class BundlesController < ApplicationController
    skip_before_action :require_login
    skip_before_action :verify_authenticity_token
    before_action :set_bundle, only: %i(create_order show)

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to signup_index_path, alert: exception.message
    end

    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to signup_index_path, notice: t(:event_not_found)
    end

    # Checkout Initialization
    # Creates a plain Order from scratch
    # POST /signup/bundles/backen-ohne-mehl
    def create_order
      redirect_to signup_index_path, notice: t(:event_not_found)
      # authorize! :signup, @bundle
      # user = current_user || User.create_external_user!
      # auto_login(user) unless logged_in?
      # @order = Order.unconfirmed.find_or_initialize_by(product_id: @bundle.id, product_type: 'Bundle', user: current_user)
      # @order.adpartner_id = params[:adpartner] if params[:adpartner].present?
      # @order.save!
      # @order.update!(paymentmethod: Paymentmethod.find_by(key: 'free')) if @bundle.free?
      # redirect_to(edit_signup_order_path(@order))
    end

    def show
      redirect_to signup_index_path, notice: t(:event_not_found)
      # @bundle = @bundle.decorate
      # render 'show', layout: 'signup_full_width'
    end

    private

    def set_bundle
      @bundle = Bundle.find_by_slug!(params[:slug])
    end
  end
end
