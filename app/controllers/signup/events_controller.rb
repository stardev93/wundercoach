module Signup
  # Starts Signup for an event
  class EventsController < ApplicationController
    rescue_from CanCan::AccessDenied do |exception|
      redirect_to signup_index_path, alert: exception.message
    end

    rescue_from ActiveRecord::RecordNotFound do |_e|
      redirect_to signup_index_path, notice: t(:event_not_found)
    end

    skip_before_action :require_login
    skip_before_action :verify_authenticity_token
    before_action :set_event, only: %i(create_order show)

    # Checkout Initialization
    # Creates a plain Order from scratch
    # POST /signup/events/backen-ohne-mehl
    def create_order
      authorize! :signup, @event
      user = current_user || User.create_external_user!
      auto_login(user) unless logged_in?
      @order = Order.unconfirmed.find_or_initialize_by(product_id: @event.id, product_type: 'Event', user: current_user)
      @order.adpartner_id = params[:adpartner] if params[:adpartner].present?
      @order.save!
      @order.update!(paymentmethod: Paymentmethod.find_by(key: 'free')) if @event.free?
      redirect_to(edit_signup_order_path(@order))
    end

    def show
      if @account
        view_partial = 'show'
        layout_partial = 'signup_full_width'
        html_status = 200
      else
        view_partial = 'not_found'
        layout_partial = 'errors'
        html_status = 404
      end
      render view_partial, layout: layout_partial, :status => html_status
    end

    private

    def set_event
      @event = Event.signupallowed.find_by_slug!(params[:slug])
    end
  end
end
