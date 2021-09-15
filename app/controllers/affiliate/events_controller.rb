class Affiliate < ActiveRecord::Base
  class EventsController < BaseController
    before_action :set_event, only: %i(show edit update destroy)
    before_action :set_filters, only: %i(index)

    # GET /affiliate/events
    def index
      @events = @affiliate.events.filter(@filters).includes(:account, :affiliate_tags).page(params[:page])
    end

    # GET /affiliate/events/1
    def show; end

    # GET /affiliate/events/1/edit
    def edit; end

    # PATCH/PUT /affiliate/events/1
    def update
      if @event.update!(event_params)
        redirect_to affiliate_event_path(@event), notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    private

    def set_event
      @event = Event.friendly.find(params[:id])
    end

    def event_params
      params.require(:event).permit(affiliate_tag_ids: [])
    end

    def search_params
      params.require(:affiliate_events).permit(:search, :start_date, :end_date, :by_account, by_affiliate_tags: [])
    end

    def set_filters
      if params[:clear]
        session[:affiliate_events_filter] = nil
      elsif params[:affiliate_events]
        session[:affiliate_events_filter] = search_params
      end
      @filters = session[:affiliate_events_filter] || {}
    end
  end
end
