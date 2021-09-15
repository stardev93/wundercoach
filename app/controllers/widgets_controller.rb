# crud-operations for widgets
class WidgetsController < ApplicationController
  before_action :set_widget, only: %i(show edit update destroy)
  authorize_resource

  # GET /widgets
  def index
    @widgets =
      if params[:search]
        Widget.where("name LIKE ?", "%#{params[:search]}%").page(params[:page]).order('name ASC')
      else
        Widget.page(params[:page]).order('name ASC')
      end
  end

  # GET /widgets/1
  def show
    authorize_feature! 'website_integration_javascript'
  end

  # GET /widgets/new
  def new
    authorize_feature! 'website_integration_javascript'
    @widget = Widget.new
  end

  # GET /widgets/1/edit
  def edit
    authorize_feature! 'website_integration_javascript'
  end

  # POST /widgets
  def create
    authorize_feature! 'website_integration_javascript'
    @widget = Widget.new(widget_params)
    if @widget.save
      redirect_to @widget, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /widgets/1
  def update
    authorize_feature! 'website_integration_javascript'
    if @widget.update(widget_params)
      redirect_to @widget, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /widgets/1
  def destroy
    authorize_feature! 'website_integration_javascript'
    @widget.destroy
    redirect_to widgets_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_widget
    @widget = Widget.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def widget_params
    params.require(:widget).permit(:name, :html, :description, :widgettype, :widgetscope)
  end
end
