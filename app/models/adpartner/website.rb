class Adpartner < ActiveRecord::Base
  # adpartners can have multiple website, each with it's own commission
  class Website < ActiveRecord::Base
    belongs_to :adpartner
    validates :commission_relative, numericality: { greater_than_or_equal_to: 0, less_than: 100 }, if: :commission_relative_changed?
    validates :commission_absolute, numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }, if: :commission_absolute_changed?

    def to_s
      url
    end

    def commission_relative
      read_attribute(:commission_relative) || adpartner.commission_relative
    end

    def commission_absolute
      read_attribute(:commission_absolute) || adpartner.commission_absolute
    end
  end
end
