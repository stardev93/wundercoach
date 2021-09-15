class DashboardController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to login_path, alert: exception.message
  end
  skip_authorization_check

  def index
    authorize! :read, ActsAsTenant.current_tenant
    @next_events = Event.upcoming.by_start_date.limit(10)
    @new_requests = Request.includes(:event).without_appointment.order(:created_at)
    @new_orders = Order.includes(:address, :product).joins(:eventbookings).confirmed.reorder(order_date: :desc).limit(10).decorate
    @show_get_started_modal = @account.show_get_started_modal == "true"
  end

  # called via ajax
  def dashboard
    authorize! :read, ActsAsTenant.current_tenant
    @dashboard = DashboardFacade.new(Date.today)

    render "dashboard", layout: false
  end
end
