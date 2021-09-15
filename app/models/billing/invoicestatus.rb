module Billing
  class Invoicestatus < ActiveRecord::Base
    self.table_name = "invoicestatuses"
    has_many :businessdocuments, foreign_key: :invoicestatus_id, class_name: "Billing::Businessdocument", dependent: :nullify

    translates :name, :description
    def to_s
      name
    end
  end
end
