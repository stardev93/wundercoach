class EventsController < ApplicationController
  load_and_authorize_resource
  before_action -> { require_feature('backend_individual_appointments') }, only: %i(new_individual new_individual_agreed_event new_individual_agreed_event_from_event)
  before_action -> { if @event.is_a? IndividualEvent then require_feature('backend_individual_appointments') end }, only: %i(edit show)

  # GET /events
  def index

    # initialize session if not existant
    session[:q] ||= Hash.new
    session[:q]['coaches_id_eq'] ||= ''
    session[:q]['product_tags_id_eq'] ||= ''
    session[:q]['onlinestatus_id_eq'] ||= ''
    session[:q]['start_date_gteq'] ||= Date.today.to_s  + 'T00:00:00'
    session[:q]['start_date_lteq'] ||= ''
    session[:q]['type_eq'] ||= ''
    session[:q]['eventtype_id_eq'] ||= ''

    # when reset button is pressed
    if params['filter'] == 'reset'
      session[:q] = Hash.new
      session[:q]['coaches_id_eq'] = ''
      session[:q]['product_tags_id_eq'] = ''
      session[:q]['onlinestatus_id_eq'] = ''
      session[:q]['start_date_gteq'] = ''
      session[:q]['start_date_lteq'] = ''
      session[:q]['type_eq'] = ''
      session[:q]['eventtype_id_eq'] = ''
    end

    if params[:q]
      # length == 10 means date was entered through datepicker field. Time is missing when using these fields, so we append it
      # don't worry about timezone, ransack does this for us
      if !params[:q]['start_date_gteq'].nil? && params[:q]['start_date_gteq'] != '' && params[:q]['start_date_gteq'].length == 10
        params[:q]['start_date_gteq'] = params[:q]['start_date_gteq'] + 'T00:00:00'
      end
      if !params[:q]['start_date_lteq'].nil? && params[:q]['start_date_lteq'] != '' && params[:q]['start_date_lteq'].length == 10
        params[:q]['start_date_lteq'] = params[:q]['start_date_lteq'] + 'T23:59:59'
      end
      # merge freshly send params with existing session, adding up filter parameters until session is cleared
      session[:q] = session[:q].merge(params[:q])
    end

    @q = Event.ransack(session[:q])
    @q.sorts = ['start_date ASC', 'events.name ASC'] if @q.sorts.empty?
    @events = @q.result(distinct: true).with_includes.where("type != 'Eventtemplate'")

    respond_to do |format|
      format.html {
          @events = @events.page(params[:page])
      }
      format.xlsx {
        authorize_feature! 'csv_export'
        @events = EventDecorator.decorate_collection(@events)
        response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:events)}-#{Date.today}.xlsx"
      }
      format.csv do
        authorize_feature! 'csv_export'
        send_data(@events.csv_list.encode("UTF-8"), :type => 'text/csv; charset=iso8859-1; header=present', filename: "#{I18n.t(:events)}-#{Date.today}.csv")
      end
      format.json do
        #render :json => @events
      end
    end
  end

  # GET /events/1
  def show
    # @event = Event.includes(completed_eventbookings: [:address, :order, eventbookingstatus: :translations]).friendly.find(params[:id]).decorate
    @event = Event.friendly.find(params[:id]).decorate
    respond_to do |format|
      format.html do
        @asset = Asset.new(event: @event)
        @mailtemplates = Mailtemplate.user_generated

        @available_subevents = Event.available_as_subevents.page(params[:availablesubevents_page])
        @available_subevents = @available_subevents.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
      end

      format.xlsx {
        authorize_feature! 'csv_export'
        if params[:csvtype] == 'email'
          @csv_email = true
        else
          @csv_email = false
        end
        response.headers['Content-Disposition'] = 'attachment; filename=' + @event.name.gsub(/[^0-9A-Za-z]/, '_') + "_#{I18n.t(:participantlist)}-#{Date.today}.xlsx"
      }
      format.csv do
        authorize_feature! 'csv_export'
        send_data((params[:csvtype] == 'email' ? @event.eventbookings.csv_email.encode("UTF-8") : @event.eventbookings.csv_full.encode("UTF-8")), :type => 'text/csv; charset=UTF-8; header=present', filename: "#{I18n.t(:participantlist)}-#{Date.today}.csv")
      end
    end
  end

  # GET /events/1
  def calendar

    # initialize session if not existant
    session[:q] ||= Hash.new
    session[:q]['onlinestatus_id_eq'] ||= ''
    session[:q]['start_date_gteq'] ||= Date.today.to_s  + 'T00:00:00'
    session[:q]['start_date_lteq'] ||= ''
    session[:q]['type_eq'] ||= ''
    session[:q]['eventtype_id_eq'] ||= ''

    # when reset button is pressed
    if params['filter'] == 'reset'
      session[:q] = Hash.new
      session[:q]['onlinestatus_id_eq'] = ''
      session[:q]['start_date_gteq'] = ''
      session[:q]['start_date_lteq'] = ''
      session[:q]['type_eq'] = ''
      session[:q]['eventtype_id_eq'] = ''
    end
    if params[:q]
      # length == 10 means date was entered through datepicker field. Time is missing when using these fields, so we append it
      # don't worry about timezone, ransack does this for us
      if !params[:q]['start_date_gteq'].nil? && params[:q]['start_date_gteq'] != '' && params[:q]['start_date_gteq'].length == 10
        params[:q]['start_date_gteq'] = params[:q]['start_date_gteq'] + 'T00:00:00'
      end
      if !params[:q]['start_date_lteq'].nil? && params[:q]['start_date_lteq'] != '' && params[:q]['start_date_lteq'].length == 10
        params[:q]['start_date_lteq'] = params[:q]['start_date_lteq'] + 'T23:59:59'
      end
      # merge freshly send params with existing session, adding up filter parameters until session is cleared
      session[:q] = session[:q].merge(params[:q])
    end

    @q = Event.ransack(session[:q])
    @q.sorts = ['start_date ASC', 'events.name ASC'] if @q.sorts.empty?
    @events = @q.result(distinct: true).includes(:onlinestatus, :planningstatus, :eventtype, :durationunit)

    respond_to do |format|
      format.html {
          @events = @events.page(params[:page])
      }
    end
  end

  # GET /events/backen-ohne-mehl/pdf
  # Generate and show pdf
  def pdf
    authorize_feature! 'printable_views'
    if params[:pdftype] == "participantlist"
      send_data(@event.participantlist_pdf, filename: "#{I18n.t(:participantlist)}.pdf", type: 'application/pdf', disposition: 'inline')
    else
      send_data(@event.attendancelist_pdf, filename: "#{I18n.t(:attendancelist)}.pdf", type: 'application/pdf', disposition: 'inline')
    end
  end

  # GET /events/new_individual
  # For creating individual events
  def new_individual
    @event = IndividualEvent.new
    @advance_payment = Paymentmethod.find_by(key: 'vorkasse')
    @event.maxparticipants = 1
    @event.max_additional_participants = 0
    @event.paymentmethods << @advance_payment
    render 'new'
  end

  # GET /events/new_free
  # For creating individual events
  def new_free
    @event = FreeEvent.new
    @event.start_date = (Time.now + 14.day).strftime('%Y-%m-%d 10:00:00')
    @event.end_date = (Time.now + 14.day).strftime('%Y-%m-%d 18:00:00')
    @event.latest_signup_date = (Time.now + 12.day).strftime('%Y-%m-%d 00:00:00')
    @event.reservation_expiry = (Time.now + 10.day).strftime('%Y-%m-%d 00:00:00')
    @event.maxparticipants = 10
    @event.max_additional_participants = 0
    render 'new'
  end

  # GET /events/new_free
  # For creating individual events
  def new_online
    @event = OnlineEvent.new
    @event.start_date = (Time.now + 14.day).strftime('%Y-%m-%d 10:00:00')
    @event.end_date = (Time.now + 14.day).strftime('%Y-%m-%d 18:00:00')
    @event.latest_signup_date = (Time.now + 12.day).strftime('%Y-%m-%d 00:00:00')
    @event.reservation_expiry = (Time.now + 10.day).strftime('%Y-%m-%d 00:00:00')
    @event.maxparticipants = 10
    @event.max_additional_participants = 0
    render 'new'
  end

  # GET /events/new_bundle
  # For creating event bundles
  def new_bundle
    @event = BundleEvent.new
    # @event.start_date = (Time.now + 14.day).strftime('%Y-%m-%d 10:00:00')
    # @event.end_date = (Time.now + 14.day).strftime('%Y-%m-%d 18:00:00')
    # @event.latest_signup_date = (Time.now + 12.day).strftime('%Y-%m-%d 00:00:00')
    # @event.reservation_expiry = (Time.now + 10.day).strftime('%Y-%m-%d 00:00:00')
    @event.maxparticipants = 10
    @event.max_additional_participants = 0
    render 'new'
  end

  def send_to_all
    mailtemplate = Mailtemplate.find(params[:template_id])
    @event.eventbookings.confirmed_bookings.each do |eventbooking|
      EventMailer.send_composed_mail(@account, eventbooking,
                                     mailtemplate,
                                     to: eventbooking.email).deliver_later
    end
    redirect_to @event, notice: t(:mail_sent_to_all)
  end

  # GET /events/new
  def new
    @event = StandardEvent.new
    @event.allow_signup = true
    @event.start_date = (Time.now + 14.day).strftime('%Y-%m-%d 10:00:00')
    @event.end_date = (Time.now + 14.day).strftime('%Y-%m-%d 18:00:00')
    @event.latest_signup_date = (Time.now + 12.day).strftime('%Y-%m-%d 00:00:00')
    @event.reservation_expiry = (Time.now + 10.day).strftime('%Y-%m-%d 00:00:00')
    @event.enable_crm = true

    @event.vat = current_tenant.default_vat
    @event.currency = current_tenant.default_currency_iso_code
    @event.maxparticipants = 10
    @event.max_additional_participants = 0
    @event.generate_invoice = true

    # no early signup pricing as default
    @event.early_signup_pricing = false
    @event.early_signup_deadline = (@event.start_date - 5.day).strftime('%Y-%m-%d 00:00:00')
    @event.price_early_signup = nil
    @event.latest_signup_date = (@event.start_date - 3.day).strftime('%Y-%m-%d 00:00:00')

    @advance_payment = Paymentmethod.find_by(key: 'vorkasse')
    @event.paymentmethods << @advance_payment
  end

  # GET /events/1/edit
  def edit
    @advance_payment = Eventpaymentmethod.joins(:paymentmethod).find_by(event: @event, paymentmethods: { key: 'vorkasse' })
  end

  # GET /events/1/duplicate
  def duplicate
    if params[:retadr]
      retadr = eventtemplate_path(@event.duplicate.eventtemplate) + '#events'
    else
      retadr = @event.duplicate
    end

    redirect_to retadr, notice: t(:event_was_successfully_duplicated)
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    @event.setup
    if @event.save
      redirect_to @event, notice: t(:event_was_successfully_created)
    else
      render action: 'new'
    end
  end

  # PUT /events/1/cancel
  def cancel
    notice =
      if @event.cancel.save
        t(:event_cancelled)
      else
        @event.errors.join(', ')
      end
    redirect_to event_path(@event), notice: notice
  end

  # PUT /events/1/regenerate_map
  def regenerate_map
    if @event.use_product_location
        @event&.product_location&.save
    else
      if @event.full_street_address.nil?
        @event.longitude = nil
        @event.latitude = nil
        @event.save!
      else
        @event.geocode
        @event.save
        @notice = t(:event_map_coordinates_were_successfully_recalculated)
      end
    end
    redirect_to event_path(@event) + '#locationoptions', notice: @notice
  end

  # PATCH/PUT /events/1
  def update
    update_params = event_params
    # only StandardEvents have paymentmethods, so we need to skip this for other events
    unless update_params[:paymentmethod_ids]&.include?(Paymentmethod.find_by(key: 'vorkasse').id)
      update_params.delete(:eventpaymentmethods_attributes)
    end
    if @event.update(update_params)
      redirect_to @event, notice: t(:event_was_successfully_updated)
    else
      render action: 'edit'
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy!
    redirect_to events_url, notice: t(:event_was_successfully_deleted)
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to event_path(@event), alert: e.message
  end


  # updates the onlinestatus from index or show
  def onlinestatus

    status = Onlinestatus.find_by(key: params[:onlinestatus])
    redirect_path = events_path
    notice = ''

    if @event.max_additional_participants.nil?
      @event.max_additional_participants = 0
    end

    if @event.valid? && status
      @event.update!(onlinestatus: status)
      notice = t(:event_was_successfully_updated)
      if params[:redirect] == 'index'
        redirect_path = events_path
      elsif params[:redirect] == 'publishingoptions'
        redirect_path = event_path(@event) + '#publishingoptions'
      # commented out 2020-08-04
      # elsif /bundle-(?<bundle_id>\d+)/ =~ params[:redirect]
      #   redirect_path = bundle_path(bundle_id)
      else
        redirect_path = event_path(@event)
      end
    else
      redirect_path = edit_event_path(@event)
      notice = t(:update_error)
    end
    redirect_to redirect_path, notice: notice
  end

  # updates the planningstatus from index or show
  def planningstatus
    status = Planningstatus.find_by(key: params[:planningstatus])
    redirect_path = events_path
    notice = ''

    if @event.max_additional_participants.nil?
      @event.max_additional_participants = 0
    end
    if @event.valid? && status
      @event.update!(planningstatus: status)
      notice = t(:event_was_successfully_updated)
      if params[:redirect] == 'index'
        redirect_path = events_path
      elsif params[:redirect] == 'publishingoptions'
        redirect_path = event_path(@event) + '#publishingoptions'
      else
        redirect_path = event_path(@event)
      end
    else
      redirect_path = edit_event_path(@event)
      notice = t(:update_error)
    end
    redirect_to redirect_path, notice: notice

  end

  def assigncoach
    @event.coaches << Coach.find(params[:coach_ids]) if params[:coach_ids]
    redirect_to event_path(@event) + '#coaches'
  end

  def removecoach
    if params[:coach_ids]
      @event.coaches.delete(Coach.find(params[:coach_ids]))
    end
    redirect_to event_path(@event) + '#coaches'
  end

  def assignsubevent
    subevent = Event.find(params[:subevent_id]) if params[:subevent_id]

    event_subevent = EventSubevent.new(
      {
        event: @event,
        subevent_id: subevent.id
      }
    )
    begin
      event_subevent.save!
      notice = t(:subevent_assigned)
    rescue
      notice = t(:subevent_already_in_bundle)
    end
    redirect_to event_path(@event) + '#subevents', notice: notice
  end

  def unassignsubevent
    subevent = EventSubevent.find(params[:subevent_id])
    subevent.destroy!
    redirect_to event_path(@event) + '#subevents', notice: t(:subevent_unassigned)
  end

  private

  def order_params
    params.require(:event).permit(order: [:order_date, address_attributes: Address::FORM_ATTRIBUTES])
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    params.require(:event).permit(
      :name, :shortdescription, :show_remaining_seats_count,
      :longdescription, :start_date, :duration, :maxparticipants, :type,
      :latest_signup_date, :full_price, :price_early_signup, :durationunit_id,
      :eventtype_id, :allow_signup, :external_signup_url, :redirect_message,
      :external_signup_text, :bottom_text, :end_date, :early_signup_deadline,
      :early_signup_pricing, :onlinestatus_id, :tags_id, :country, :digimember_id,
      :planningstatus_id, :generate_invoice, :vat_id, :location, :street,
      :streetno, :zip, :city, :state, :latitude, :longitude, :reservation_expiry,
      :googlemapslocation, :slug, :eventtemplate_id, :currency, :enable_crm,
      :comments, :product_pricingset_id, :product_location_id, :use_product_location,
      :max_additional_participants, :eventorganizer, :webinar_url, :webinar_url_valid_from, :webinar_provider, :webinar_help_url,
      :webinar_username, :webinar_pw, :webinar_additional_information, :webinar_additional_information_short, :contact_information, paymentmethod_ids: [], product_tag_ids: [],
      affiliate_tag_ids: [],
      eventpaymentmethods_attributes: %i(available_until paymentmethod_id id)
    )
  end
end
