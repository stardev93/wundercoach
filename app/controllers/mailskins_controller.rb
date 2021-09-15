class MailskinsController < ApplicationController
  before_action :set_mailskin, only: %i(show edit update destroy preview)
  authorize_resource

  # GET /mailskins
  def index
    @mailskins = Mailskin
                 .joins(:translations)
                 .with_translations(I18n.locale)
                 .page(params[:page])
                 .order('mailskin_translations.name ASC')
    @mailskins = @mailskins.where("mailskin_translations.name LIKE ?", "%#{params[:search]}%") if params[:search]
  end

  # GET /mailskins/1
  def show; end

  # GET /mailskins/1/preview
  def preview
    if params[:mailtemplate_id]
      mailtemplate = Mailtemplate.find(params[:mailtemplate_id])
      eventbooking = Eventbooking.all.first
      @html = @mailskin.render(mailtemplate.substituted_html(eventbooking)).html_safe
    else
      @html = @mailskin.render.html_safe
    end
    render layout: false
  end

  # GET /mailskins/new
  def new
    @mailskin = Mailskin.new
  end

  # GET /mailskins/1/edit
  def edit
    @mailskinasset = Mailskinasset.new
    @mailskinasset.mailskin = @mailskin
  end

  # POST /mailskins
  def create
    @mailskin = Mailskin.new(mailskin_params)

    if @mailskin.save
      redirect_to @mailskin, notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /mailskins/1
  def update
    if @mailskin.update(mailskin_params)
      redirect_to @mailskin, notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /mailskins/1
  def destroy
    @mailskin.destroy
    redirect_to mailskins_url, notice: t(:delete_successful)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mailskin
    @mailskin = Mailskin.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mailskin_params
    params.require(:mailskin).permit(:key, :name, :htmlbody, :textbody)
  end
end
