# filter by the event's price
class PriceFilter < Filter
  def self.model_name
    Filter.model_name
  end

  ALLOWED_COMPARATORS = %i(eql gt lt gte lte).freeze
  COMPARATOR_MAPPING = {
    'eql' => '=',
    'gt'  => '>',
    'lt'  => '<',
    'gte' => '>=',
    'lte' => '<='
  }.freeze

  validates :comparator, inclusion: { in: ALLOWED_COMPARATORS.map(&:to_s) }, presence: true
  monetize :price_cents

  def scope_name
    :filter_by_price
  end

  def scope_params
    [price_cents, COMPARATOR_MAPPING[comparator]]
  end
end
