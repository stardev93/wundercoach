class MailskinassetsController < ApplicationController
  before_action :set_mailskinasset, only: %i(show edit update destroy remove)
  authorize_resource

  # GET /mailskinassets
  def index
    @mailskinassets = if params[:search]
                        Mailskinasset.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).order('name ASC')
                      else
                        Mailskinasset.page(params[:page]).order('name ASC')
    end
  end

  # GET /mailskinassets/1
  def show; end

  # GET /mailskinassets/new
  def new
    @mailskinasset = Mailskinasset.new
  end

  # GET /mailskinassets/load
  def load
    @mailskin = Mailskin.find(params[:mailskin_id])
    @mailskinasset = Mailskinasset.new
  end

  # GET /mailskinassets/1/edit
  def edit; end

  # POST /mailskinassets
  def create
    # @upload = Upload.create(upload_params)
    @mailskinasset = Mailskinasset.new(mailskinasset_params)
    if @mailskinasset.save
      # send success header
      render json: { message: 'success', fileID: @mailskinasset.id }, status: 200
    else
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @mailskinasset.errors.full_messages.join(',') }, status: 400
    end
  end

  # PATCH/PUT /mailskinassets/1
  def update
    if @mailskinasset.update(mailskinasset_params)
      redirect_to edit_mailskin_path(@mailskinasset.mailskin_id), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /mailskinassets/1
  def destroy
    @mailskinasset.destroy
    redirect_to mailskinassets_url, notice: t(:delete_successful)
  end

  # GET /mailskinassets/1/remove
  def remove
    mailskinasset = @mailskinasset
    file_name = mailskinasset.mailskinasset_file_name || ''
    @mailskinasset.destroy
    redirect_to edit_mailskin_path(mailskinasset.mailskin), notice: t(:file_successfully_deleted, file: file_name)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mailskinasset
    @mailskinasset = Mailskinasset.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mailskinasset_params
    params.require(:mailskinasset).permit(:mailskin_id, :mailskinasset)
  end
end
