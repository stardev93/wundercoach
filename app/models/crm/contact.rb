module Crm
  class Contact < ActiveRecord::Base

    before_validation :set_account_receivable_no
    self.table_name = "contacts"

    acts_as_tenant(:account)

    has_many :contact_addresses, class_name: Crm::ContactAddress, dependent: :destroy
    has_many :contact_details, class_name: Crm::ContactDetail, dependent: :destroy
    has_many :contact_taggings, dependent: :destroy
    has_many :contact_tags, through: :contact_taggings
    has_many :persons, foreign_key: :contact_id, class_name: "Contact", dependent: :destroy
    has_many :businessdocuments, foreign_key: :contact_id, class_name: "Billing::Businessdocument", dependent: :nullify
    has_many :invoices, foreign_key: :contact_id, class_name: "Billing::Invoice", dependent: :nullify
    has_many :quotes, foreign_key: :contact_id, class_name: "Billing::Quote", dependent: :nullify
    has_many :cancellations, foreign_key: :contact_id, class_name: "Billing::Cancellation", dependent: :nullify
    has_many :orderconfirmations, foreign_key: :contact_id, class_name: "Billing::Orderconfirmation", dependent: :nullify
    has_many :eventbookings

    belongs_to :account
    belongs_to :company, class_name: 'Contact', :foreign_key => 'contact_id'

    #validates :name, presence: true

    # default_scope -> { order('name') }
    scope :with_addresses, -> { includes(:contact_addresses) }
    scope :with_tags, -> { includes(:contact_taggings, :contact_tags) }

    scope :companies, -> { where(type: 'Company') }

    # scope :invoices, -> { includes(:businessdocuments).where(businessdocuments: { type: 'Billing::Invoice'}) }
    # scope :quotes, -> { includes(:businessdocuments).where(businessdocuments: { type: 'Billing::Quote'}) }
    # scope :orders, -> { include(:businessdocuments).where(businessdocuments: { type: 'Billing::Order'}) }
    # scope :cancellations, -> { include(:businessdocuments).where(businessdocuments: { type: 'Billing::Cancellation'}) }

    CONTACT_TYPES = [ "contact_customer", "contact_lead", "contact_partner", "contact_supplier"]

    def get_primary_address
      self.contact_addresses.where(is_primary: true).first
    end

    # get the next higher number for businessdocument.type
    def get_next_account_receivable_no
      # delivers value 0 when no record is found - not nil or blank
      account_receivable_no_start = 0
      new_number = Crm::Contact.maximum('account_receivable_no').to_i

      if new_number.blank? || new_number.nil? || new_number == 0
        account_receivable_no_start = account.account_receivable_no_start
      else
        account_receivable_no_start = new_number.to_i + 1
      end
      return account_receivable_no_start
    end

    # make sure persons get the name field filled
    def add_full_name
      self.name = "#{lastname}, #{firstname}"
      true
    end

    def self.get_duplicates(name = nil, email = nil)
      # find all contacts with
      # - emailaddress in contact_details.detail_value
      # - contact.name
      # - contact.lastname and contact.firstname
      if email.nil?
        retval = Crm::Contact.joins("LEFT JOIN contact_details ON contacts.id = contact_details.contact_id").where("name LIKE ?", "%#{name}%").distinct
      else
        retval = Crm::Contact.joins("LEFT JOIN contact_details ON contacts.id = contact_details.contact_id").where("name LIKE ? OR detail_value LIKE ?", "%#{name}%", "%#{email}%").distinct
      end
      return retval
    end

    private

    def set_account_receivable_no
      # is autonumbering activated, does the contact have no superior contact it is attached to and is the field empty?
      if self.account.account_receivable_autonumbering && !contact_id && (self.account_receivable_no.blank? || self.account_receivable_no.nil?)
        self.account_receivable_no = get_next_account_receivable_no.to_i
      end
      true
    end
  end

end
