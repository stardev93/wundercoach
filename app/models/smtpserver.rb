class Smtpserver < ActiveRecord::Base
  require 'resolv'
  acts_as_tenant(:account)
  belongs_to :account

  # Validators
  validates :key, uniqueness: { scope: :account }
  validates :from_name, presence: true, on: :update
  validates :replyto_address, presence: true, on: :update, if: :wundercoach_standard?
  validates :replyto_address, email: true, on: :update, if: :wundercoach_standard?
  validates :from_address, email: true

  validates :from_address, presence: true, on: :update, if: :custom?
  validates :from_address, email: true, on: :update, if: :custom?

  validates :server, presence: true, on: :update, if: :custom?
  validates :port, presence: true, on: :update, if: :custom?
  validates :username, presence: true, on: :update, if: :custom?
  validates :password, presence: true, on: :update, if: :custom?

  # Scopes
  default_scope { order('id') }
  scope :activated, -> { where('active = true') }
  scope :custom, -> { where('key = custom') }

  def wundercoach_standard?
    true if key == "wundercoach_standard"
  end

  def custom?
    true if key == "custom"
  end

  def name
    "smtpserver_#{key}_name"
  end

  def description
    "smtpserver_#{key}_description"
  end

  # check if a smtpserversetting can be activated
  def can_activate?
    if custom?
      unless server.blank? || port.blank? || username.blank? || password.blank? || from_address.blank?
        true
      else
        false
      end
    elsif wundercoach_standard?
      unless replyto_address.blank?
        true
      else
        false
      end
    end
  end

  def to_s
    key
  end

  def activate
    if can_activate?
      deactivate_all

      # activate self
      self.active = true
      self.save
      return self
    else
      false
    end
  end

  # returns the Mailer.delivery_method options for merging
  def get_delivery_options
    # do we use the custom mail configuration?
    if custom?
      smtp_settings = {
                        user_name: username,
                        password: password,
                        address: server,
                        port: port,
                        ssl: ssl,
                        authentication: authentication,
                        openssl_verify_mode: openssl,
                        enable_starttls_auto: starttls
                      }
    else
      smtp_settings = {
                        user_name: username,
                        password: password,
                        address: server,
                        port: port,
                        ssl: ssl
                      }
    end
  end

  # return the custom smtpserver object
  def self.get_active
    Smtpserver.activated.first
  end

  # return the custom smtpserver object
  def self.get_custom
    Smtpserver.find_by(key: 'custom')
  end

  # deactivate all active smtpservers - called whan a new server is activated
  # Smtpserver class method is scoped, so only account.smtpservers are fetched.
  def deactivate_all
    Smtpserver.activated.update_all active:false
  end

  # populate Smtpserver for given account when
  # Class method, called from accounts_controller smtpserversettings
  def self.populate(account)
    Smtpserver.create([
      {account: account, key: 'wundercoach_standard', server: "mail.businesshosting24.com", port: "465", username: "go@wundercoach.net", password: "61d2c1Uk4", ssl: true, active: true, from_address: "go@wundercoach.net", from_name: account.name, replyto_address: account.email},
      {account: account, key: 'custom', server: "", port: "", username: "", password: "", ssl: true, active: false, from_address: account.email, from_name: account.name, replyto_address: account.email}
      ])
  end

  def self.get_smtp_settings
    @smtpserver = Smtpserver.activated.get_delivery_options
  end

  def self.authentication_types
    %w{PLAIN LOGIN CRAM5D}
  end
end
