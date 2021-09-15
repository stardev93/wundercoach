class Affiliate < ActiveRecord::Base
  # allows affiliates to tag events with their own tags
  class TagsController < BaseController
    before_action :set_tag, only: %i(show edit update destroy)

    # GET /affiliate/tags
    def index
      @tags = if params[:search]
                @affiliate.tags.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
              else
                @affiliate.tags.page(params[:page]).order('name ASC')
      end
    end

    # GET /affiliate/tags/1
    def show; end

    # GET /affiliate/tags/new
    def new
      @tag = Tag.new
    end

    # GET /affiliate/tags/1/edit
    def edit; end

    # POST /affiliate/tags
    def create
      @tag = @affiliate.tags.build(tag_params)
      if @tag.save
        redirect_to affiliate_tag_path(@tag), notice: t(:creation_successful)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /affiliate/tags/1
    def update
      if @tag.update(tag_params)
        redirect_to affiliate_tag_path(@tag), notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    # DELETE /affiliate/tags/1
    def destroy
      @tag.destroy
      redirect_to affiliate_tags_url, notice: t(:delete_successful)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = @affiliate.tags.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tag_params
      params.require(:affiliate_tag).permit(:name)
    end
  end
end
