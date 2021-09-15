require "#{Rails.root}/app/services/billing/invoice_freeze"
require "#{Rails.root}/app/services/billing/invoice_create_pdf"

module Billing
  class Businessdocument < ActiveRecord::Base
    acts_as_tenant(:account)

    include HasCountry
    include Filterable

    nilify_blanks

    # Hooks
    # before_validation :prepare_record, on: :create
    before_destroy :protect_from_deletion

    # Relations
    belongs_to :account
    belongs_to :contact, class_name: 'Crm::Contact', :foreign_key => 'contact_id'
    belongs_to :contact_address, class_name: 'Crm::ContactAddress', :foreign_key => 'contact_address_id'
    belongs_to :order, :foreign_key => 'order_id'
    belongs_to :invoicestatus, class_name: 'Billing::Invoicestatus', :foreign_key => 'invoicestatus_id'
    belongs_to :invoicetype, class_name: 'Billing::Invoicetype', :foreign_key => 'invoicetype_id'
    belongs_to :paymentstatus
    belongs_to :address, autosave: true, dependent: :destroy
    belongs_to :predecessor, class_name: 'Billing::Businessdocument', foreign_key: 'predecessor'
    has_one :successor, class_name: 'Billing::Businessdocument', foreign_key: 'predecessor'

    has_many :businessdocumentpositions, class_name: 'Billing::Businessdocumentposition', foreign_key: 'businessdocument_id', dependent: :destroy
    has_attached_file :pdf, path: ':rails_root/private:url'

    accepts_nested_attributes_for :address, :account

    # Validation
    validates_attachment :pdf, content_type: { content_type: 'application/pdf' }

    default_scope { order(id: :desc) }

    # The following Scopes are used as filters in the invoice index action
    # if you change them, you have to adapt invoice#index, too!
    scope :search, lambda {|search|
      joins(:address)
        .where("name LIKE :pattern
                OR recipient_name1 LIKE :pattern
                OR recipient_name2 LIKE :pattern
                OR invoice_number = :search
                OR addresses.email LIKE :pattern
                OR addresses.firstname LIKE :pattern
                OR addresses.lastname LIKE :pattern",
               search: search, pattern: "%#{search}%")
    }
    scope :start_date, ->(date) { where('invoice_date >= ?', date) }
    scope :end_date, ->(date) { where('invoice_date <= ?', date) }
    scope :by_year, ->(date) { start_date(date.beginning_of_year).end_date(date.end_of_year) }
    scope :by_month, ->(date) { start_date(date.beginning_of_month).end_date(date.end_of_month) }
    scope :invoicetype, ->(id) { where(invoicetype_id: id) }
    scope :paymentmethod, ->(id) { joins(:order).where(orders: { paymentmethod_id: id }) }
    scope :paymentstatus, ->(id) { where(paymentstatus_id: id) }
    scope :by_type, ->(key) { joins(:invoicetype).where(businessdocuments: { type: key }) }

    def is_invoice?
      if type == "Billing::Invoice"
        true
      else
        false
      end
    end

    def paymentmethod
      if order && order.paymentmethod
        order.paymentmethod
      else
        nil
      end
    end
    # get from account settings if amount given as event prices include VAT or if they are net prices
    # ToDo: store this setting in self Businessdocument when it is created
    def vat_included?
      # get settings from account and store it if object.vat_included is empty
      if vat_included.blank?
        account.vat_included
      else
        vat_included
      end
    end

    # can the object (i.e. invoice) be cancelled?
    # only invoices can be cancelled for now
    # ToDo: align this with invoice.frozen?
    def can_cancel?
      true
    end

    # check if self has a follow up document (successor)
    def get_predecessor
      return Billing::Businessdocument.find_by(id: predecessor)
    end

    # check if self has a predecessor up document (successor)
    def get_successor
      return Billing::Businessdocument.find_by(predecessor: id)
    end

    def cancellation?
      type == 'Billing::Cancellation'
    end

    # is the cancelled flag set?
    def cancelled?
      cancelled
    end

    # get the next higher number for businessdocument.type
    def get_next_number(type)
      # delivers value 0 when no record is found - not nil or blank
      new_number = Billing::Businessdocument.by_type(type).maximum('invoice_number').to_i
      if new_number.blank? || new_number.nil? || new_number == 0
        # || new_number.zero?
        new_number = self.account.cancellation_no_start
      else
        new_number = new_number + 1
      end
      return new_number
    end

    # get the pdfs filename
    def get_pdf_filename
      "#{I18n.t(:invoice)}_#{self.invoice_number}.pdf"
    end

    def create_pdf
      puts "NJSDIJNAJIFSAJDFJHIASIJFDJI"
      # call service InvoiceCreatePdf
      @invoice = InvoiceCreatePdf.new(self).perform
      return @invoice
    end

    # freeze the document so it cannot be edited
    def document_freeze
      return InvoiceFreeze.new(self).perform unless frozen?
    end

    # return true if pdf-file exists
    def pdf_exists?
      if self.pdf.path
        File.exist?(pdf.path)
      else
        false
      end
    end

    # in invoice is frozen if it has an invoice_number,
    # i.e. it has been sent to the customer or printed
    def frozen?
      if invoice_number.blank?
        false
      else
        true
      end
    end

    # def next_document_number
    # end

    # get the next higher number for invoice object
    # or return the start value
    def next_document_number
      self.invoice_number = get_next_number(type) || account.invoice_no_start
      self.save!
    end

    # document_freeze first
    # call the service for sending self
    def document_send
      return InvoiceSend.new(self).perform
    end

    # sum of all businessdocumentpositions without VAT
    def net_sum
      if vat_included?
        businessdocumentpositions.to_a.sum(&:total_price_net)
      else
        businessdocumentpositions.to_a.sum(&:total_price)
      end

    end

    # sum of businessdocumentpositions VAT
    def vat_sum
      businessdocumentpositions.to_a.sum(&:total_vat_amount)
    end

    # get array of all businessdocumentpositions VAT amounts
    # one array element per VAT type
    # ToDo: make this work -> one row per vat_id with sums of vat, use the decorator
    def vat_sums
      vats = []
      businessdocumentpositions.joins(:vat).select("vat_id as vatname, sum(price_cents) as vat_sum").group("vat_id").each do |vat_pos|
        vats << { "#{vat_pos.vatname}" => vat_pos.vat_sum }
      end
      return vats
    end

    # sum of all businessdocumentpositions with VAT
    def gross_sum
      net_sum + vat_sum
    end

    # params for WickedPdf used in #create_pdf
    def pdf_options
      {
        margin: {
          top: '30mm',
          bottom: '40mm',
          left: '10mm',
          right: '10mm'
        }
      }
    end

    def paid?
      paymentstatus.key == 'paid'
    end

    def due?
      Date.today > due_date unless due_date.nil?
    end

    def can_duplicate?
      true
    end

    # duplicate the current object
    def duplicate
      if can_duplicate?
        new = deep_clone include: [:businessdocumentpositions]
        new.invoice_number = nil
        new.save!
      end
    end

    def email
      self.recipient_email
    end

    # return account_receivable_no from self or from assigned contact
    def get_account_receivable_no
      ar_no = ''
      if !account_receivable_no.blank?
        ar_no = account_receivable_no.to_s
      else
        if contact
          ar_no = contact.account_receivable_no.to_s
        end
      end
      return ar_no
    end

    def get_costcenter
      costcenter.nil? ? account.costcenter : costcenter
    end

    private

    def prepare_record
      # get vat_included from account and store it in object
      # this attribute must remain frozen as it contains the way VAT is calculated
      vat_included = account.vat_included

      # invoicetype = case type
      # when "Billing::Quote" then Billing::Invoicetype.find_by(key: "quote")
      # when "Billing::Orderconfirmation" then Billing::Invoicetype.find_by(key: "orderconfirmation")
      # when "Billing::Invoice" then Billing::Invoicetype.find_by(key: "invoice")
      # when "Billing::Cancellation" then Billing::Invoicetype.find_by(key: "cancellation")
      # end
    end

    def protect_from_deletion
      return true if invoicestatus.key == 'new'
      raise ActiveRecord::RecordNotDestroyed, I18n.t(:cannot_delete_sent_invoice)
    end
  end
end
