# placeholders are text sniplets that represent object properties
class Placeholder < ActiveRecord::Base

  scope :by_objecttype, -> { order("objecttype") }
  scope :by_name, -> { order("name") }
  scope :by_sortorder, -> { order("sortorder") }
  scope :objecttype_filter, -> (objecttype) { where('objecttype = ?', objecttype) }

  enum localisation_type: %i(default date currency)

  def to_s
    name
  end

  def localised_substitution(replacements)
    localise substitution(replacements)
  end

  # Localises a value depending on type (e.g. date, currency)
  def localise(value)
    if date? && value.respond_to?(:strftime)
      I18n.l value.to_date
    elsif currency?
      ActionController::Base.helpers.number_to_currency value, unit: value.symbol
    else
      value
    end
  end

  # Substitute by calling a method on an object
  # e.g. if you want to replace {event.name}, replacements should
  # contain 'event' => event, where event is an object that responds to name,
  # e.g. an event-record
  def substitution(replacements)
    object_name, method_name = name[1..-2].split(".")
    object = replacements[object_name]
    method = method_name.to_sym

    if object.nil? || !object.respond_to?(method)
      ""
    else
      # call object.method
      object.public_send(method)
    end
  end

  # Substitution Methods

  # substitutes placeholders in message body and subject
  # substituable = object like eventbooking
  # text: the text where replacements should be made
  # returns a hash with replaced subject and message
  def self.substitute_placeholders(substitutable, text)
    # get the array of objects that relate to substitutable
    @@replacements = substitutable.to_substitution_hash

    # All placeholders look like this pattern
    # e.g. {event.name}
    placeholder_pattern = /\{\w+\.\w+\}/

    # finds all placeholders and executes them, returns substituted text
    text.gsub(placeholder_pattern) {|s| execute_placeholder(s) }
  end

  # calls method on object if object and method are valid
  # returns result of the method or empty string if invalid
  def self.execute_placeholder(placeholder_name)
    placeholder = Placeholder.find_by(name: placeholder_name)
    if placeholder.nil?
      ""
    else
      placeholder.localised_substitution(@@replacements)
    end
  end
end
