class Crm::ContactTagDecorator < Draper::Decorator
  delegate_all

  def name
    return h.truncate(h.strip_tags(object.name), :length => 25, :separator => ' ', omission: '...')
  end

  def comments
    return h.truncate(h.strip_tags(object.comments), :length => 50, :separator => ' ', omission: '...')
  end

end
