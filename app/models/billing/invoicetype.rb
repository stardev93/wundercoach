module Billing
  class Invoicetype < ActiveRecord::Base
    self.table_name = "invoicetypes"
    has_many :businessdocuments, foreign_key: :invoicetype_id, class_name: "Billing::Businessdocument", dependent: :nullify

    translates :name, :description
    def to_s
      name
    end
  end
end
