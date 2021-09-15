class BundlesEventsController < ApplicationController
  before_action :set_bundle_and_event
  before_action { authorize! :update, @bundle }

  # add event to bundle
  def update
    @event.bundles << @bundle
    redirect_to :back
  end

  # remove event from bundle
  def destroy
    @event.bundles.delete(@bundle)
    redirect_to :back
  end

  private

  def set_bundle_and_event
    @bundle = Bundle.find(params[:bundle_id])
    @event = Event.find(params[:id])
  end
end
