# Manages an Event's Orders
class Bundle::OrdersController < OrdersController
  before_action :set_product

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Bundle.friendly.find(params[:bundle_id])
  end
end
