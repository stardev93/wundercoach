# filter by the event's eventtype
class TypeFilter < Filter
  def self.model_name
    Filter.model_name
  end

  belongs_to :eventtype

  validates :eventtype, presence: true

  def scope_name
    :filter_by_eventtype
  end

  def scope_params
    [eventtype_id]
  end
end
