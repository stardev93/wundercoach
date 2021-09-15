# This Controller exposes show, edit, update and destroy in routes.rb
# Both Bundle::OrdersController and Event::OrdersController derive from this,
# that's why index, new and create are defined here, too
class OrdersController < ApplicationController
  before_action :set_order, only: :destroy

  # GET /events/backen-ohnne-mehl/orders/new
  # GET /bundles/backen-ohnne-mehl/orders/new
  def new
    # called from event/order_controller, which inherits from this controller
    @model = Order.new(product: @product, address: Address.new, billing_address: Address.new)
    @form = Order::CreateForm.new(@model)

  end

  # POST /events/backen-ohne-mehl/orders
  # POST /bundles/backen-ohne-mehl/orders
  def create
    result = Order::Create.call(params[:order], "product" => @product)
    @model = result["model"]
    if result.success?
      redirect_to event_path(@model.product) + '#bookings', notice: t(:order_creation_successful)
    else
      @form = result["contract.default"]
      render action: 'new'
    end
  end

  # GET /orders/1/edit
  def edit
    form Order::Update
  end

  # PATCH/PUT /orders/1
  def update
    run Order::Update do
      return redirect_to @model.product, notice: t(:order_update_successful)
    end
    render action: 'edit'
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    product = @order.product
    redirect_to product, notice: t(:order_delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end
end
