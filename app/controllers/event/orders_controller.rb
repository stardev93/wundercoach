# Manages an Event's Orders
class Event::OrdersController < OrdersController
  before_action :set_product

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Event.friendly.find(params[:event_id])
  end
end
