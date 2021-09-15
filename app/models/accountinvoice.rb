# represents an Invoice from Wundercoach to an account for charging wundercoach services
# Do not mix up with Billing::Businessdocument of type Invoice which is send to account's clients for booked events
class Accountinvoice < ActiveRecord::Base
  include HasCountry
  acts_as_tenant(:account)
  belongs_to :accountinvoicetype
  belongs_to :accountinvoicestatus

  has_one :successor, foreign_key: "successor_id", class_name: "Accountinvoice"
  has_one :predecessor, foreign_key: "predecessor_id", class_name: "Accountinvoice"
  has_one :billing_period, dependent: :nullify

  scope :by_type, ->(key) { joins(:accountinvoicetype).where(accountinvoicetypes: { key: key }) }

  has_many :accountinvoicepositions, dependent: :destroy

  validates :invoice_date, :invoice_number, :recipient_name_1, :street, :street_no, :zip, :city, :country, :accountinvoicetype_id, :accountinvoicestatus_id, presence: true
  validates_uniqueness_to_tenant :invoice_number

  has_attached_file :pdf, path: ':rails_root/private:url'
  validates_attachment :pdf, content_type: { content_type: "application/pdf" }

  def to_s
    accountinvoicetype.name + ' ' + invoice_number.to_s
  end

  # true if the document is an invoice, false for cancellations
  def is_cancelled?
    successor.present?
  end

  # do we have a german account?
  def is_de?
    c = ISO3166::Country[country.upcase]
    c.alpha2 == "DE"
  end

  # do we have a eu country / but not germany?
  def is_eu_ext?
    c = ISO3166::Country[country.upcase]
    c.in_eu? && c.alpha2 != "DE"
  end

  # calculate the correct vat depending on customer location
  # rules:
  # customer in germany: net_value + vat 19% = gross value, gross_value beeing the plans price
  # customer in EU but outside germany: customer pays gross_value, VAT-ID ist needed and needs to be confirmed with
  # customer outside EU: customer pays gross_value, no VAT-ID ist needed
  def get_vat
    iso_c = ISO3166::Country[country.upcase]
    # are we in EU?
    # return Vat.find_by(key: "no_vat_world") unless iso_c.in_eu?

    # Germany? => German tax applies
    if iso_c.alpha2 == "DE"
      # do we have to use Corona Vat?
      if invoice_date <= '2020-12-31'.to_date
        Vat.find_by(key: "regular_vat_reduced")
      else
        Vat.find_by(key: "regular_vat")
      end

    elsif iso_c.in_eu?
      #reverse charge: no vat for eu countries
      Vat.find_by(key: "no_vat_eu")
    else
      # rest of EU? => Tax of other EU-country applies, but not here
      Vat.find_by(key: "no_vat_world")
    end
  end

  def get_next_number(type)
    ActsAsTenant.without_tenant do
      new_number = Accountinvoice.by_type(type).maximum("invoice_number").to_i
      if new_number.blank? || new_number.zero?
        if type == 'invoice'
          10_000
        else
          20_000
        end
      else
        new_number + 1
      end
    end
  end

  def next_invoicenumber(type = "invoice")
    self.invoice_number =
      case type
      when "invoice"
        get_next_number(type) || 10_000
      when "cancellation"
        get_next_number(type) || 20_000
      end
  end

  # TODO: Turn this into a class method
  # create a new invoice for billing_period.
  # billing_period is referenced in accountinvoicepositions
  def create_new(billing_period, accountinvoicetype = "invoice", accountinvoicestatus = "new")
    account = billing_period.account
    today = Date.today
    ActsAsTenant.with_tenant(account) do
      if account.name
        rec1 = account.name
        rec2 = account.name_addon
      else
        rec1 = "#{account.firstname} #{account.lastname}"
        rec2 = nil
      end
      accountinvoice = Accountinvoice.new({
        invoice_date: today,
        email_to: account.email_billing_address,
        accountinvoicetype: Accountinvoicetype.find_by(key: accountinvoicetype),
        invoice_number: get_next_number('invoice'),
        recipient_name_1: rec1,
        recipient_name_2: rec2,
        street: account.street,
        street_no: account.streetno,
        zip: account.zip,
        city: account.city,
        country: account.country,
        accountinvoicestatus: Accountinvoicestatus.find_by(key: accountinvoicestatus),
        paymentmethod: billing_period.paymentmethod,
        paymentdate: billing_period.paymentdate
      })
      accountinvoice.additional_text = I18n.t(:reverse_charge_infotext) if billing_period.account.is_eu_ext?
      accountinvoice.save!
      billing_period.accountinvoice = accountinvoice
      billing_period.save!

      Accountinvoiceposition.new.create_new(accountinvoice, billing_period)
      accountinvoice
    end
  end

  def cancel(accountinvoice)
    cancellation = accountinvoice.dup
    cancellation.invoice_number = next_invoicenumber('cancellation')
    cancellation.accountinvoicetype = Accountinvoicetype.find_by(key: 'cancellation')
    cancellation.accountinvoicestatus = Accountinvoicestatus.find_by(key: 'new')
    cancellation.invoice_date = Date.today
    cancellation.predecessor = accountinvoice
    cancellation.save!

    # set successor of original accountinvoice to cancellation
    accountinvoice.successor = cancellation
    accountinvoice.save!

    accountinvoice.accountinvoicepositions.each do |accountinvoiceposition|
      cancellation_position = accountinvoiceposition.dup
      cancellation_position.accountinvoice_id = cancellation.id
      cancellation_position.amount = accountinvoiceposition.amount * -1
      # cancellation_position.net_price = accountinvoiceposition.net_price * -1
      cancellation_position.gross_price = accountinvoiceposition.gross_price * -1
      cancellation_position.vat_sum = accountinvoiceposition.vat_sum * -1
      cancellation_position.save
      # raise "new: " + cancellation_position.amount.to_s
    end
    cancellation
  end

  # get the gross sum of all positions
  def get_gross_sum
    gross_sum = 0.to_f
    accountinvoicepositions.each do |accountinvoiceposition|
      gross_sum = gross_sum.to_f + accountinvoiceposition.gross_price.to_f
    end
    gross_sum.to_f
  end

  # get the net sum of all positions
  def get_net_sum
    net_sum = 0.to_f
    accountinvoicepositions.each do |accountinvoiceposition|
      net_sum += (accountinvoiceposition.net_price.to_f * accountinvoiceposition.amount.to_f)
    end

    case get_vat.key
    when "regular_vat"
      return net_sum.to_f
    when "regular_vat_reduced"
      return net_sum.to_f
    when "no_vat_eu"
      return get_gross_sum.to_f
    when "no_vat_world"
      return get_gross_sum.to_f
    end
  end

  # get the vat sum of all positions
  def get_vat_sum
    vat_sum = 0.to_f
    accountinvoicepositions.each do |accountinvoiceposition|
      vat_sum += accountinvoiceposition.vat_sum.to_f
    end
    vat_sum.to_f
  end

  def create_pdf
    #File.delete(pdf.path.to_s) if File.exist?(pdf.path.to_s)
    html_options = ['accountinvoices/pdf/pdf.html', layout: 'accountinvoice_pdf.html', locals: { :@accountinvoice => self }]

    tmp_base_path = Rails.root.join("tmp", "accountinvoices", account_id.to_s)
    FileUtils.mkdir_p(tmp_base_path) unless File.directory?(tmp_base_path)
    tmp_path = Rails.root.join(tmp_base_path, "#{I18n.t(:invoice)}_#{invoice_number}.pdf")

    generator = ::PdfGenerator.new(html_options, pdf_options, tmp_path)
    generator.footer_html_options = ['accountinvoices/pdf/footer.html', layout: 'accountinvoice_pdf.html']
    generator.header_html_options = ['accountinvoices/pdf/header.html', layout: 'accountinvoice_pdf.html']
    generator.create_pdf
    self.pdf = File.open(tmp_path)
    File.delete(tmp_path) if File.exist?(tmp_path)
  end

  def create_and_send_pdf
    create_pdf
    save!
    AccountinvoiceMailer.send_invoice(self).deliver_later
  end

  private

  def pdf_options
    {
      margin: {
        top: '20mm',
        bottom: '14mm'
      }
    }
  end
end
