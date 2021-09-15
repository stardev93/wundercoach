module Billing
  class Businessdocumentposition < ActiveRecord::Base
    acts_as_tenant(:account)
    acts_as_list scope: :businessdocument

    # belongs_to :invoice
    belongs_to :businessdocument, class_name: "Billing::Businessdocument"
    belongs_to :product, polymorphic: true
    belongs_to :order
    belongs_to :vat
    belongs_to :eventbooking

    delegate :vat_included?, to: :businessdocument

    # use price_cents for storing money in cents, use currency for storing the currency
    # sliently adds field "price" that hold price_cents in format for currency
    monetize :price_cents, with_model_currency: :currency, numericality: { message: 'Für kostenlose Seminare werden keine Rechnungen erstellt.' }

    # default_scope { order(position: :asc) }

    validates :vat, presence: true

    #delegate currency to businessdocument
    def currency
      businessdocument&.currency
    end

    # new price functions

    # always give the price of a single unit
    # no matter if it is with or without tax
    def unit_price
      price
    end

    # return the net price of a single unit
    def unit_price_net
      if vat_included?
        price / (1 + vat.value)
      else
        price
      end
    end

    # always give the price of a single unit by amount
    # no matter if it is with or without tax
    def total_price
      unit_price * amount
    end

    # return the total price including tax
    def gross_sum
      total_price
    end

    def total_price_net
      if vat_included?
        (unit_price * amount) / (1 + vat.value)
      else
        unit_price * amount
      end
    end

    # calculate the vat from total_price depending on vat_included? true or false
    def total_vat_amount
      if vat_included? && vat.value != 0
        # prices are gross - including tax: get tax from gross price
        total_price - total_price_net
      else
        # prices are net, without tax: add tax to price
        total_price * vat.value
      end
    end

    # calculate the vat from total_price depending on vat_included? true or false
    def unit_vat_amount
      if vat_included?
        # prices are gross - including tax: get tax from gross price
        unit_price / (1 + vat.value)
      else
        # prices are net, without tax: add tax to price
        unit_price * vat.value
      end
    end

    # get the vat percentage value
    def vat_rate
      self.vat.value
    end

    # duplicate the current object
    def duplicate
      new = self.dup
      new.save!
    end

    # get the contact for a businessdocumentposition from its businessdocument
    def get_contact
      businessdocument&.contact
    end

    private

    # Calculations for included vat
    def gross_price_included
      price * amount
    end

    def net_price_included
      gross_price_included / (1 + vat.value)
    end

    def vat_price_included
      gross_price_included - net_price_included
    end

    # Calculations for excluded vat
    def net_price_excluded
      price * amount
    end

    def vat_price_excluded
      price * amount * vat.value
    end

  end
end
