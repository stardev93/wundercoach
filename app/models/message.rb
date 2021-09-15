class Message < ActiveRecord::Base

  translates :subject, :body

  has_many :usermessages, dependent: :destroy
  has_many :users, through: :user_messages

  validates_presence_of :subject, :body

  scope :showing, -> { where("published_at <= ?", DateTime.now).order("published_at DESC") }

  def to_s
    subject
  end

  # has the message been published in users/messages
  def published?
    !published_at.nil?
  end

  # has the message been pushed to users list of unread messages
  def pushed?
    !pushed_at.nil?
  end
end
