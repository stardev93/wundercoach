class Affiliate < ActiveRecord::Base
  # crud operations for adpartner's websites
  class WebsitesController < BaseController
    before_action :set_adpartner_website, only: %i(show edit update destroy)
    before_action :set_adpartner, only: %i(index new create)

    # GET /adpartner/websites
    def index
      @websites = Adpartner::Website.page(params[:page]).order('id ASC')
    end

    # GET /adpartner/websites/1
    def show; end

    # GET /adpartner/websites/new
    def new
      @adpartner_website = Adpartner::Website.new(adpartner: @adpartner)
    end

    # GET /adpartner/websites/1/edit
    def edit; end

    # POST /adpartner/websites
    def create
      @adpartner_website = Adpartner::Website.new(adpartner_website_params)
      @adpartner_website.adpartner = @adpartner
      if @adpartner_website.save
        redirect_to affiliate_website_path(@adpartner_website), notice: t(:creation_successful)
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /adpartner/websites/1
    def update
      if @adpartner_website.update(adpartner_website_params)
        redirect_to @adpartner_website, notice: t(:update_successful)
      else
        render action: 'edit'
      end
    end

    # DELETE /adpartner/websites/1
    def destroy
      @adpartner = @adpartner_website.adpartner
      @adpartner_website.destroy
      redirect_to affiliate_adpartner_url(@adpartner, anchor: 'websites'), notice: t(:delete_successful)
    end

    private

    def set_adpartner_website
      @adpartner_website = Adpartner::Website.find(params[:id])
    end

    def set_adpartner
      @adpartner = Adpartner.find(params[:adpartner_id])
    end

    # Only allow a trusted parameter "white list" through.
    def adpartner_website_params
      params.require(:adpartner_website).permit(:url, :commission_relative, :commission_absolute)
    end
  end
end
