# Creates Coaching Appointments
# Updating and deleting Events is handled by the events controller
class IndividualAgreedEventsController < ApplicationController
  after_action :set_generated_event_on_request, only: :create
  # GET /events/backen-ohne-mehl/new_appointment
  def new_from_event
    @coaching = Event.friendly.find(params[:slug])
    @event = IndividualAgreedEvent.new_from_event(@coaching)
    @event.orders.build(order_date: Time.now, address_attributes: {})
    render 'new'
  end

  # GET /requests/1/new_appointment
  # For creating agreed individual events
  def new
    @request = Request.find(params[:id])
    @event = IndividualAgreedEvent.new_from_request(@request)
  end

  # POST /requests/:request_id/appointment
  def create
    create_event
  end

  # POST /events/backen-ohne-mehl/appointment
  def create_from_event
    create_event
  end

  private

  def set_generated_event_on_request
    Request.find(params[:request_id]).update!(generated_event: @event) if @event.persisted?
  end

  def create_event
    @event = Event.new(event_params)
    if @event.max_additional_participants.nil?
      @event.max_additional_participants = 0
    end
    if @event.maxparticipants.nil?
      @event.maxparticipants = 1
    end
    @event.setup
    if @event.save!
      @event.orders.each do |order|
        order.paymentmethod = @event.paymentmethods.first
        order.confirm
      end
      redirect_to @event, notice: t(:event_was_successfully_created)
    else
      render 'new'
    end
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    params.require(:event).permit(
      :name, :shortdescription,
      :longdescription, :start_date, :duration, :maxparticipants, :type,
      :latest_signup_date, :full_price, :price_early_signup, :durationunit_id,
      :eventtype_id, :allow_signup, :external_signup_url, :redirect_message,
      :external_signup_text, :bottom_text, :end_date, :early_signup_deadline,
      :early_signup_pricing, :onlinestatus_id, :country,
      :planningstatus_id, :generate_invoice, :vat_id, :location, :street,
      :streetno, :zip, :city, :latitude, :longitude, :reservation_expiry,
      :googlemapslocation, :slug, :eventtemplate_id, :currency,
      :max_additional_participants, :request, paymentmethod_ids: [],
      orders_attributes: [:order_date, address_attributes: Address::FORM_ATTRIBUTES],
      eventpaymentmethods_attributes: %i(available_until paymentmethod_id id)
    )
  end
end
