module Crm
  class Crm::ContactAddress < ActiveRecord::Base

    before_save :make_primary_if_required

    validates :city, presence: true

    include HasCountry

    self.table_name = "contact_addresses"
    acts_as_tenant(:account)

    belongs_to :account
    belongs_to :contact, class_name: Crm::Contact, foreign_key: "contact_id"

    has_many :businessdocuments, foreign_key: :contact_address_id, class_name: "Billing::Businessdocument", dependent: :nullify

    # default_scope -> { order('country, city') }
    scope :primary_first, -> { order('is_primary DESC') }
    scope :primary, -> { where(is_primary: true) }

    def make_primary
      self.contact.contact_addresses.each do |contact_address|

        if contact_address.id == self.id
          contact_address.is_primary = true
        else
          contact_address.is_primary = false
        end
        contact_address.save
      end

    end

    private

    def make_primary_if_required
      unless self.contact.contact_addresses.any?
        self.is_primary = true
      end
    end

  end
end
