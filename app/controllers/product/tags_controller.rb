class Product::TagsController < ApplicationController
  before_action :set_event_tag, only: %i(show edit update destroy)

  # GET /event/tags
  def index
    @tags = Product::Tag.page(params[:page]).order('name ASC')
    @tags = @tags.where("name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /event/tags/1
  def show
    @events = @tag.events.by_name.page(params[:eventtemplatepage])
    @eventtemplates = @tag.eventtemplates.by_name.page(params[:eventtemplatepage])
  end

  # GET /event/tags/new
  def new
    @tag = Product::Tag.new
  end

  # GET /event/tags/1/edit
  def edit; end

  # POST /event/tags
  def create
    @tag = Product::Tag.new(product_tag_params)
    if @tag.save
      redirect_to @tag, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /event/tags/1
  def update
    if @tag.update(product_tag_params)
      redirect_to @tag, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /event/tags/1
  def destroy

    @tag.destroy
    redirect_to event_tags_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event_tag
    @tag = Product::Tag.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def product_tag_params
    params.require(:product_tag).permit(:name)
  end
end
