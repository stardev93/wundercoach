class Mailtemplate < ActiveRecord::Base
  acts_as_tenant(:account)

  belongs_to :mailskin

  before_create :flag_as_user_generated
  before_destroy :prevent_destroying_system_relevant_mailtemplates

  validates :key, :name, :subject, :message, presence: true
  validates :key, uniqueness: { scope: :account }
  validate :key_not_changed, on: :update

  scope :system, -> { where(account: nil) }
  scope :user_generated, -> { where(is_system: false) }

  attr_readonly :is_system

  translates :name, :subject, :message

  def to_s
    name
  end

  # render the mails outer html
  def render_mailskin(eventbooking)
    # get the inner html with placegolder substitutions
    mailskin.render(substituted_html(eventbooking))
  end

  # get the message body with placeholders substituted
  # pass in eventbooking and message from mailtemplate_translations
  # who is handling translations?
  def substituted_html(eventbooking)
    # pass object with data and text with placeholders for replacing
    Placeholder.substitute_placeholders(eventbooking, message)
  end

  # get the message subject with placeholders substituted
  def substituted_subject(eventbooking)
    # pass object with data and text with placeholders for replacing
    Placeholder.substitute_placeholders(eventbooking, subject)
  end

  # render the message's subject for context
  def render_subject(context)
    # pass object with data and text with placeholders for replacing
    Placeholder.substitute_placeholders(eventbooking, subject)
  end

  # render the message's body for context
  # context: determines the set of placeholders available
  # i.e. rendering the context invoice contains all related fields for invoices
  # while the context for an eventbooking might not contain an invoice when no invoice has been generated
  def render_body(context, placeholders)
    Placeholder.get_placholders(eventbooking, subject)
  end

  # merge the templates own mailer options
  def mailer_options(eventbooking)
    options = {
      subject: substituted_subject(eventbooking)
    }
    options
  end

  private

  def key_not_changed
    errors.add(:key, :changed) if is_system && key_changed?
  end

  def flag_as_user_generated
    self.is_system ||= false
    true
  end

  def prevent_destroying_system_relevant_mailtemplates
    !is_system
  end
end
