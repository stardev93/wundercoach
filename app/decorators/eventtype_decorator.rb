class EventtypeDecorator < Draper::Decorator

  delegate_all

  def colorcode
    if object&.colorcode&.empty?
      "#e9e9e9"
    else
      object&.colorcode
    end
  end
end
