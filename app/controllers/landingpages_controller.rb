class LandingpagesController < ApplicationController
  skip_before_action :require_login, only: %i(index show)
  skip_authorization_check

  before_action :set_eventtemplate, only: [:show, :edit, :update, :destroy, :createevent, :editseo, :saveseo, :eventshow]
  before_action -> { require_feature("seo_tagging") }, only: :editseo

  #authorize_resource

  # GET /landingpages
  def index
    @eventtemplates = Eventtemplate.page(params[:page]).order('name ASC')
    render 'index', layout: 'signup_full_width'
  end

  # GET /landingpages/1
  def show
    @meta_title = @eventtemplate.meta_title
    @meta_description = @eventtemplate.meta_description
    @meta_keywords = @eventtemplate.meta_keywords
    @name = @eventtemplate.name
    @shortdescription = @eventtemplate.shortdescription
    @longdescription = @eventtemplate.longdescription
    @events = @eventtemplate.events.all
    render 'show', layout: 'landingpage'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eventtemplate
      @eventtemplate = Eventtemplate.friendly.find(params[:id])
    end

end
