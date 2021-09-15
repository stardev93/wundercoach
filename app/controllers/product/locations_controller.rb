class Product::LocationsController < ApplicationController
  before_action :set_product_location, only: %i(show edit update destroy removeicon generatemaps downloaddirectionspdf removedirectionspdf)

  # GET /product/locations
  def index
    # @product_locations = Product::Location.all
    # @product_locations = Location.page(params[:page]).order('id ASC')
    @locations = if params[:search]
      Product::Location.where('location_name LIKE ? or eventorganizer_name LIKE ? or street LIKE ? or city LIKE ? or country LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%").page(params[:page]).order('location_name ASC')
    else
      Product::Location.page(params[:page]).order('location_name ASC')
    end
  end

  # GET /product/locations/1
  def show
      @product_location = @product_location.decorate
  end

  # GET /product/locations/new
  def new
    @product_location = Product::Location.new
  end

  # GET /product/locations/1/edit
  def edit
  end

  # POST /product/locations
  def create
    @product_location = Product::Location.new(product_location_params)
    if @product_location.save
      redirect_to @product_location, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  def generatemaps
    @product_location.save

    redirect_to @product_location
  end

  # delete the uploaded icon
  def removeicon
    @product_location.icon = nil
    @product_location.save

    redirect_to @product_location, notice: t(:location_icon_successfully_deleted)
  end

  # PATCH/PUT /product/locations/1
  def update
    if @product_location.update(product_location_params)
      redirect_to @product_location, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /product/locations/1
  def destroy
    @product_location.destroy
    redirect_to product_locations_url, notice: t(:delete_successful)
  end

  # download the directions pdf if it exists
  def downloaddirectionspdf
    if @product_location.directionspdf.exists?
      send_file(@product_location.directionspdf.path, filename: @product_location.directionspdf_file_name, type: 'application/pdf', disposition: 'inline')
    end
  end

  # delete the uploaded icon
  def removedirectionspdf
    @product_location.directionspdf = nil
    @product_location.save

    redirect_to @product_location, notice: t(:location_directionspdf_successfully_deleted)
  end

  private

  def set_product_location
    @product_location = Product::Location.find(params[:id])
  end

  def product_location_params
    params.require(:product_location).permit(:eventorganizer_name, :location_name, :street, :zip, :city, :state, :country, :googlemapslocation,
      :latitude, :longitude, :displayed_address, :icon, :time_zone, :show_time_zone_in_checkout, :directions, :directionspdf, :cost_fixed, :cost_variable, :cost_variable_unit, :street_no)
  end
end
