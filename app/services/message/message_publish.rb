# Add a new Contact from eventboookingBusinessdocuments
# ContactCreateFromEventbooking.new(@eventbooking).perform
class MessagePublish

  # initialize with invoice object to send an invoice
  def initialize(message)
    @message = message
  end

  # show the message in users list of messages
  def publish
    @message.published_at = DateTime.now
    @message.save
  end

  # hide the message from users list of messages
  def unpublish
    @message.published_at = nil?
    @message.save
  end

  # add the @message to usermessages so it is displayed in the users sidebar
  def push
    User.internal.all.each do |user|
      begin
        user.messages << @message
        user.save
      rescue
        # Don't show Exceptions here
        # when save fails there is a duplicate entry on index [user_id, message_id]
      end
    end
    @message.pushed_at = DateTime.now
    @message.save
  end

  # remove the @message from usermessages so it isn't displayed in the users dashboard
  def mute
    Usermessage.where("message_id=?", @message.id).each do |usermessage|
      usermessage.destroy
    end
    @message.pushed_at = nil
    @message.save
  end

end
