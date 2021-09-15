class EventtemplatesController < ApplicationController
  before_action :set_eventtemplate, only: %i(show edit update destroy createevent editseo saveseo eventshow duplicate updateevents)
  before_action -> { require_feature('seo_tagging') }, only: :editseo
  before_action -> { authorize_feature!('event_templates') }
  authorize_resource

  # GET /eventtemplates
  def index
    @eventtemplates = Eventtemplate.page(params[:page]).order('name ASC')
    @eventtemplates = @eventtemplates.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # GET /eventtemplates/1
  def show
    @events = @eventtemplate.events.with_includes.by_start_date.page(params[:eventpage])
    @propagation_form = PropagationForm.new(@eventtemplate)
  end

  # GET /eventtemplates/1/createevent
  def createevent
    @event = Event.create_from_template(@eventtemplate)
    redirect_to @event
  end

  # GET /eventtemplates/new
  def new
    @eventtemplate = Eventtemplate.new
  end

  # GET /eventtemplates/1/edit
  def edit; end

  # GET /eventtemplates/1/editseo
  def editseo
    if @eventtemplate.meta_title.blank?
      @eventtemplate.meta_title = @eventtemplate.name
    end
    if @eventtemplate.meta_description.blank?
      @eventtemplate.meta_description = @eventtemplate.shortdescription
    end
    render template: 'eventtemplates/editseo'
  end

  # POST /eventtemplates
  def create
    @eventtemplate = Eventtemplate.new(eventtemplate_params.merge(account: current_user.account))
    if @eventtemplate.save
      redirect_to @eventtemplate, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /eventtemplates/1
  def update
    if @eventtemplate.update(eventtemplate_params)
      redirect_to @eventtemplate, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # PATCH/PUT /eventtemplates/1/saveseo
  def saveseo
    if @eventtemplate.update(eventtemplate_params)
      url = url_for controller: 'eventtemplates', id: @eventtemplate.id, action: 'show', anchor: 'eventtemplateseo', only_path: true
      redirect_to url, notice: t(:delete_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /eventtemplates/1
  def destroy
    @eventtemplate.destroy
    redirect_to eventtemplates_url, notice: t(:eventtemplate_was_successfully_deleted)
  end

  # GET /eventtemplates/1/duplicate
  def duplicate
    redirect_to @eventtemplate.duplicate, notice: t(:eventtemplate_was_successfully_duplicated)
  end

  def updateevents

    @eventtemplate = EventtemplateEventServices.new.propagate_attributes(@eventtemplate, params['propagation'])

    redirect_to eventtemplate_path(@eventtemplate) + '#events', notice: t(:subevents_were_successfully_updated)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_eventtemplate
    @eventtemplate = Eventtemplate.friendly.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def eventtemplate_params
    params.require(:eventtemplate).permit(
      :name, :shortdescription, :city, :use_tracking, :slug, :currency,
      :longdescription, :duration, :maxparticipants, :full_price,
      :price_early_signup, :durationunit_id, :eventtype_id, :allow_signup,
      :external_signup_url, :external_signup_text, :bottom_text,
      :early_signup_pricing, :colorcode, :generate_invoice, :location, :zip,
      :street, :country, :googlemapslocation, :streetno, :digimember_id,
      :redirect_message, :max_additional_participants, :meta_keywords,
      :product_pricingset_id, :comments,
      :make_public, :meta_title, :meta_description, :eventorganizer, :use_product_location, :propagation['copy_shortdescription'], :product_location_id, product_tag_ids: []

    )
  end
end
