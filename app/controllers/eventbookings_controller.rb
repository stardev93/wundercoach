class EventbookingsController < ApplicationController
  before_action :set_eventbooking, only: %i(show edit update destroy createinvoice cancel send_test certificate createcontact move movetoevent)
  before_action :set_filter, only: :index
  authorize_resource

  # GET /eventbookings
  def index
    @eventbookings = Eventbooking.by_date_desc.completed.filter(@filters).includes(:address, :event, :eventbookingstatus, order: :paymentmethod, order: :businessdocuments).order('addresses.lastname ASC, addresses.firstname ASC')
    respond_to do |format|
      format.html { @eventbookings = @eventbookings.page(params[:page]) }
      format.xlsx {
        authorize_feature! 'csv_export'
        if params[:csvtype] == 'email'
          @csv_email = true
        else
          @csv_email = false
        end
        response.headers['Content-Disposition'] = 'attachment; filename=' + "#{I18n.t(:participantlist)}-#{Date.today}.xlsx"
      }
      format.csv do
        authorize_feature! 'csv_export'
        send_data((params[:csvtype] == 'email' ? @eventbookings.csv_email : @eventbookings.csv_full).encode("UTF-8"), :type => 'text/csv; charset=iso8859-1; header=present', filename: "#{I18n.t(:participantlist)}-#{Date.today}.csv")
      end
      format.pdf do
        authorize_feature! 'printable_views'
        send_data(Eventbooking.bookinglist_pdf(@eventbookings), filename: "#{I18n.t(:participantlist)}.pdf", type: 'application/pdf', disposition: 'inline')
      end
    end
  end

  # GET /eventbookings/1
  def show
    @eventbooking = @eventbooking.decorate
    @event = @eventbooking.event&.decorate
    @businessdocuments = @eventbooking.order&.businessdocuments
  end

  # GET /events/backen-ohne-mehl/pdf
  # Generate and show pdf
  def certificate
    authorize_feature! 'printable_views'
    # decorate the eventbooking
    eventbooking = EventbookingDecorator.new(@eventbooking)
    # fetch the apropriate template
    @pdf_template = Pdftemplate.find(params[:pdftemplate_id])
    # invoke liquid and parse pdf_template
    # @html = Liquid::Template.parse(@pdf_template.body_code).render(eventbooking.context)

    @pdf = eventbooking.certificate_pdf(@pdf_template)

    send_data(@pdf, filename: eventbooking.certificate_pdf_filename, type: 'application/pdf', disposition: 'inline')

  end

  # POST /eventbookings/1/send_test/1
  def send_test
    mailtemplate = Mailtemplate.find(params[:template_id])
    EventMailer.send_composed_mail(@account, @eventbooking,
                                   mailtemplate,
                                   to: current_user.email).deliver_later
    redirect_to :back, notice: t(:test_mail_has_been_sent)
  end

  # GET /eventbookings/1/edit
  def edit
    @event = @eventbooking.event
    unless @eventbooking.billing_address
      billing_address = @eventbooking.address.dup
      billing_address.save
      @eventbooking.billing_address = billing_address
      @eventbooking.save!
      @eventbooking.order.billing_address = billing_address
      @eventbooking.order.save!
    end

  end

  # POST /eventbookings
  def create
    @eventbooking = Eventbooking.new(eventbooking_params)
    if @eventbooking.save
      url = url_for controller: 'events', id: @eventbooking.event.id, action: 'show', anchor: 'eventbookings', only_path: true
      redirect_to url, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventbookings/1
  def update
    if @eventbooking.update(eventbooking_params)
      url = url_for controller: 'events', id: @eventbooking.event.id, action: 'show', anchor: 'eventbookings', only_path: true
      # redirect_to url, notice: t(:update_successful)
      redirect_to eventbooking_path(@eventbooking), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventbookings/1
  def destroy
    if params[:r] == 'eventbooking'
      redir_path = eventbookings_path
    else
      @event = @eventbooking.event
      redir_path = event_path(@event)
    end

    # ToDo: Deletion causes error, fix this.
    @eventbooking.destroy!
    redirect_to redir_path
    # , notice: t(:delete_successful)
  rescue
    # Add errors of dependent models (each error only once)
    @eventbooking.errors.add(:base, t(:delete_error)) if @eventbooking.valid?
    @eventbooking.errors[:base] << @eventbooking.invoices.reject {|invoice| invoice.errors.empty? }.map {|invoice| invoice.errors.full_messages }.uniq
    redirect_to eventbooking_path(@eventbooking), alert: @eventbooking.errors.full_messages.join(', ')
  end

  # create a new invoice
  def createinvoice
    if params[:partial] && params[:partial] == 'true'
      #authorize_feature! 'eventbundles'
      @invoice = @eventbooking.create_partial_invoice
    else
      @invoice = @eventbooking.create_invoice
    end
    redirect_to billing_businessdocument_path(@invoice)
  rescue ActiveRecord::RecordInvalid
    redirect_to :back, alert: 'Für diese Anmeldung kann keine Rechnungen erstellt werden.'
  rescue Order::CannotInvoiceError => error
    redirect_to :back, alert: error.message
  end

  # PUT /eventbookings/1/cancel
  def cancel
    eventbooking = EventbookingService.new.cancel_eventbooking(@eventbooking)
    if params[:returl] == "event"
      returl = event_path(eventbooking.event)
    else
      returl = eventbooking_path(eventbooking)
    end
    redirect_to returl, notice: t(:booking_successfully_cancelled)
  end

  # GET /eventbookings/1/move
  def move
    # eventbooking = EventbookingService.new.move_eventbooking(@eventbooking)
    # if params[:returl] == "event"
    #   returl = event_path(eventbooking.event)
    # else
    #   returl = eventbooking_path(eventbooking)
    # end
    # redirect_to returl, notice: t(:booking_successfully_cancelled)
  end

  # PATCH/PUT /eventbookings/1
  def movetoevent
    if @eventbooking.update(eventbooking_params)
      url = url_for controller: 'events', id: @eventbooking.event.id, action: 'show', anchor: 'eventbookings', only_path: true
      # redirect_to url, notice: t(:update_successful)
      redirect_to eventbooking_path(@eventbooking), notice: t(:move_eventbooking_successful)
    else
      render action: 'edit'
    end
  end

  # GET /eventbookings/1/createcontact
  def createcontact
    authorize_feature! 'contact_manager'
    @contact = ContactCreateFromEventbooking.new(@eventbooking).perform
    @ContactAddToBusinessdocument = ContactAddToBusinessdocument.new(@eventbooking).perform
    if @contact
      notice = t(:contact_created)
    else
      notice = t(:error_creating_contact)
    end
    redirect_to eventbooking_path(@eventbooking), notice: notice
  end
  private

  def set_filter
    if params[:clear]
      session[:eventbooking_filter] = nil
    elsif params[:eventbooking]
      session[:eventbooking_filter] = search_params
    end
    session[:eventbooking_filter] ||= {}
    if params[:eventbookingstatus]
      session[:eventbooking_filter]['by_status'] ||= []
      if session[:eventbooking_filter]['by_status'].include? params[:eventbookingstatus]
        session[:eventbooking_filter]['by_status'].delete(params[:eventbookingstatus])
      else
        session[:eventbooking_filter]['by_status'] << params[:eventbookingstatus]
      end
      session[:eventbooking_filter]['by_status'] = session[:eventbooking_filter]['by_status'].uniq
      return redirect_to eventbookings_path, notice: 'filter applied.'
    end
    @filters = session[:eventbooking_filter]
  end

  # Only allow a trusted parameter "white list" through.
  def search_params
    params.require(:eventbooking).permit(:search, :start_date, :end_date, :eventbookingstatus)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_eventbooking
    @eventbooking = Eventbooking.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def eventbooking_params
    params.require(:eventbooking).permit(
      :event_id, :payment_date, :paymentstatus_id,
      :booking_date, :price, :early_booking_applies,
      :eventbookingstatus_id, :country, :vat_id, :comment,
      order_attributes: [ :id, :price ],
      address_attributes: Address::FORM_ATTRIBUTES, billing_address_attributes: Address::FORM_ATTRIBUTES
    )
  end
end
