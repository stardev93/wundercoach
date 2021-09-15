class Company < Crm::Contact

  validates :name, presence: true

  def to_s
    name
  end

  def self.model_name
    Crm::Contact.model_name
  end
end
