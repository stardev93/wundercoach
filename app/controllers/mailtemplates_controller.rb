class MailtemplatesController < ApplicationController
  before_action :set_mailtemplate, only: %i(show edit update destroy)
  authorize_resource

  # GET /mailtemplates
  def index
    @mailtemplates = Mailtemplate.joins(:translations).with_translations(I18n.locale).page(params[:page]).order('name ASC')
    @mailtemplates = @mailtemplates.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  def mailto
    if params[:mailtemplate_id]
      @mailtemplate = Mailtemplate.find(params[:mailtemplate_id])
    else
      @mailtemplate = Mailtemplate.all.first
    end
    if params[:eventbooking_id]
      @eventbooking = Eventbooking.find(params[:eventbooking_id])
    end
    @mailtemplates = Mailtemplate.joins(:translations).with_translations(I18n.locale).page(params[:page]).order('name ASC')
    @mailtemplates = @mailtemplates.where('name LIKE ?', "%#{params[:search]}%") if params[:search]
  end

  # post /mailtemplates/:eventbooking_id/sendmail/:mailtemplate_id
  def sendmail
    @mailtemplate = Mailtemplate.find(params[:mailtemplate_id])
    @eventbooking = Eventbooking.find(params[:eventbooking_id])
    @address = Address.find(params[:address_id])

    if @address && @address.email
      EventMailer.send_composed_mail(@mailtemplate.account, @eventbooking, @mailtemplate, to: @address.email).deliver_later
      # EventMailer.send_composed_mail(@mailtemplate.account, @eventbooking, @mailtemplate, to: "stefan.luetge@siliconplanet.com").deliver_later
    end

    redirect_to mailtemplate_mailto_eventbooking_path(@eventbooking, @mailtemplate), notice: t(:mail_has_been_sent_to, email: @address.email)
  end
  # GET /mailtemplates/1
  def show; end

  # GET /mailtemplates/new
  def new
    @mailtemplate = Mailtemplate.new
    @placeholders = Placeholder.all
  end

  # GET /mailtemplates/1/edit
  def edit
    @placeholders = Placeholder.by_sortorder.all
  end

  # POST /mailtemplates
  def create
    @mailtemplate = Mailtemplate.new(mailtemplate_params)
    if @mailtemplate.save
      redirect_to @mailtemplate, notice: t(:creation_successful)
    else
      @placeholders = Placeholder.all
      render action: 'new'
    end
  end

  # PATCH/PUT /mailtemplates/1
  def update
    if @mailtemplate.update(mailtemplate_params)
      redirect_to @mailtemplate, notice: t(:update_successful)
    else
      @placeholders = Placeholder.all
      render action: 'edit'
    end
  end

  # DELETE /mailtemplates/1
  def destroy
    if @mailtemplate.destroy
      redirect_to mailtemplates_url, notice: t(:delete_successful)
    else
      redirect_to mailtemplates_url, alert: t(:mailtemplate_delete_error)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mailtemplate
    @mailtemplate = Mailtemplate.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mailtemplate_params
    params.require(:mailtemplate).permit(:key, :name, :subject, :message, :sender, :reply_to, :is_system, :mailskin_id)
  end
end
