class Affiliate < ActiveRecord::Base
  class EventListsController < BaseController
    before_action :set_affiliate_event_list, only: %i(show edit update destroy)

    # GET /affiliate/event_lists
    def index
      @event_lists = if params[:search]
                       @affiliate.event_lists.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
                     else
                       @affiliate.event_lists.page(params[:page]).order('name ASC')
      end
    end

    # GET /affiliate/event_lists/1
    def show; end

    # GET /affiliate/event_lists/new
    def new
      @event_list = EventList.new
    end

    # GET /affiliate/event_lists/1/edit
    def edit; end

    # POST /affiliate/event_lists
    def create
      @event_list = EventList.new(event_list_params)
      @event_list.affiliate = @affiliate
      if @event_list.save
        redirect_to affiliate_event_list_url(@event_list), notice: t(:creation_successful)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /affiliate/event_lists/1
    def update
      if @event_list.update(event_list_params)
        redirect_to affiliate_event_list_url(@event_list), notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    # DELETE /affiliate/event_lists/1
    def destroy
      @event_list.destroy
      redirect_to affiliate_event_lists_url, notice: t(:delete_successful)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_affiliate_event_list
      @event_list = Affiliate::EventList.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_list_params
      params.require(:affiliate_event_list).permit(:affiliate_id, :name, :description, tag_ids: [])
    end
  end
end
