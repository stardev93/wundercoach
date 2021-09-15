class Crm::ContactDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def name
    if object.type == 'Person'
      # name = ''
      # unless object.gender.blank?
      #   name = I18n.t(:"#{object.gender}_indirect") + ' '
      # end
      # name = name + object.firstname + ' ' + object.lastname
      object.name
    else
      object.name
    end
  end

  def gender
    I18n.t(:"#{object.gender}") unless object.gender.blank?
  end

  def gender_indirect
    I18n.t(:"#{object.gender}_indirect") unless object.gender.blank?
  end

end
