class Admin::MessagesController < Admin::AdminController
  before_action :set_message, only: %i(show edit update destroy publish unpublish push mute)

  # GET /messages
  def index
    # @messages = Message.all
    # @messages = Message.page(params[:page]).order('id ASC')
    @messages = if params[:search]
      Message.with_translations(I18n.locale).where('subject LIKE ? or body LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%").page(params[:page]).order('published_at DESC, id DESC')
    else
      Message.with_translations(I18n.locale).page(params[:page]).order('published_at DESC, id DESC')
    end
  end

  # GET /messages/1
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
    #@message.valid_from = (Time.now + 1.day).strftime('%Y-%m-%d 00:00:00')
    #@message.online = false
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  def create
    @message = Message.new(message_params)
    if @message.save
      redirect_to admin_message_path(@message), notice: t(:creation_successful)
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      redirect_to admin_message_path(@message), notice: t(:update_successful)
    else
      render action: 'edit'
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
    redirect_to admin_messages_path, notice: t(:delete_successful)
  end

  # mute this message for users
  # so the message is not shown as unread in sidebar menue
  def push
    MessagePublish.new(@message).push
    if params[:redirect] == 'index'
      return_url = admin_messages_path
    else
      return_url = admin_message_path(@message)
    end
    redirect_to return_url, notice: t(:message_push_successful)
  end

  # mute this message for users
  # so the message is not shown as unread in sidebar menue
  def mute
    MessagePublish.new(@message).mute
    if params[:redirect] == 'index'
      return_url = admin_messages_path
    else
      return_url = admin_message_path(@message)
    end
    redirect_to return_url, notice: t(:message_mute_successful)
  end

  # publish this message to be displayed in user/messages
  def publish
    MessagePublish.new(@message).publish
    if params[:redirect] == 'index'
      return_url = admin_messages_path
    else
      return_url = admin_message_path(@message)
    end
    redirect_to return_url, notice: t(:message_publishing_successful)
  end

  # unpublish this message so it is not displayed in user/messages
  def unpublish
    MessagePublish.new(@message).unpublish
    if params[:redirect] == 'index'
      return_url = admin_messages_path
    else
      return_url = admin_message_path(@message)
    end
    redirect_to return_url, notice: t(:message_unpublishing_successful)
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:subject, :body, :published_at, :pushed_at)
  end
end
