class Person < Crm::Contact
  before_save :add_full_name
  validates :lastname, presence: true

  scope :by_name, -> { order('lastname ASC, firstname ASC') }

  def to_s
    "#{lastname}#{(firstname.nil? ? '' : ', ')} #{firstname}"
  end

  def self.model_name
    Crm::Contact.model_name
  end

  private

end
