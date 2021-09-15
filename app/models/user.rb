# Implements user functionality, like logging in and out, activation and resetting password
# all authorization is based on the current user, too
class User < ActiveRecord::Base
  rails_admin do
    exclude_fields :crypted_password, :salt
  end
  nilify_blanks

  acts_as_tenant(:account)

  include HasCountry

  belongs_to :account
  has_many :eventbookings
  has_many :userroles, dependent: :destroy
  has_many :roles, through: :userroles
  has_many :invoices
  has_many :usermessages, dependent: :destroy
  has_many :messages, through: :usermessages

  # Sorcery authentication: https://github.com/Sorcery/sorcery
  authenticates_with_sorcery!

  # default_scope { order(lastname: :asc) }
  scope :by_name, -> { order(lastname: :asc, firstname: :asc) }
  scope :participants, -> { joins(:role).where("roles.name = 'client'") }
  scope :internal, -> { where(external: false) }
  scope :external, -> { where(external: true) }
  scope :search, lambda {|search|
    where("lastname LIKE :search
           OR firstname LIKE :search
           OR email LIKE :search",
          search: "%#{search}%")
  }

  def to_s
    if complete?
      "#{firstname} #{lastname}"
    else
      email
    end
  end

  def greeting
    if lastname.present? && firstname.present?
      "#{firstname} #{lastname}"
    else
      email
    end
  end

  def generate_password
    # generates a generic string, containing "a-z", "A-Z", "-" and "_"
    # length may vary, but will usually be longer than 8 chars
    password = SecureRandom.urlsafe_base64(8)
    self.password = password
    password
  end

  def internal?
    !external
  end

  def self.create_external_user!
    user = User.new
    user.email = SecureRandom.uuid
    user.password = 'dummy_user'
    user.roles << Role.find_by(name: 'client')
    user.external = true
    user.save!
    user
  end

  # assign role to user
  def assignrole(role)
    roles << role unless roles.exists?(role)
  end

  def revokerole(role)
    roles.delete(role)
  end

  def activated?
    activation_state == 'active'
  end

  # checks if full name is given
  def complete?
    lastname.present? && firstname.present?
  end

  def has_role?(role)
    !roles.detect {|k| k.name == role.to_s }.nil?
  end

  # returns if 'client' is the only role of this user.
  def client?
    roles.count == 1 && has_role?('client')
  end

  # TODO: Mailchimp deserves an own Service
  # Registers the user at Mailchimp, so he'll get some initial aid via email automation
  def register_at_mailchimp!
    if ENV['RAILS_ENV'] == 'production' && ENV['mailchimp_api_key'].present? && ENV['initial_aid_list_id'].present?
      gibbon = Gibbon::Request.new(api_key: ENV['mailchimp_api_key'])
      list_id = ENV['initial_aid_list_id']
      gibbon.lists(list_id).members.create(
        body: {
          email_address: email,
          status: 'subscribed'
        }
      )
    else
      Rails.logger.info "On production, I would have registered #{self} at mailchimp."
    end
  end

  def admin?
    has_role?('admin')
  end

  # remove role from userrole collection
  def removerole(userrole)
    userrole.delete if userroles.count > 1
  end

  def days_since_last_seen
    (Date.today - last_activity_at.to_date).to_i
  end

  # does the user have new messages?
  # true if his has_message - flag is true and there are messages at all
  def has_message?
    has_message
    # && messages.count > 0
  end

  def unread_message_count
    messages.count
  end

  # get most recent message with scope showing
  def get_last_message
    Message.showing.last
  end

  # set the users flag "has_message" to false so messages in Application won't be displayed
  def mutemessages
    self.has_message = false
    self.save
  end

  # set the users flag "has_message" to true so messages in Application will be displayed
  # this is a class method that will be called on all users simultaniously
  def self.unmutemessages
    User.all.each do |user|
      user.has_message = true
      user.save
    end
  end

  def get_time_zone
    if time_zone == ''
      account.get_time_zone
    else
      time_zone
    end
  end

  private

  def new_user?
    new_record?
  end
end
