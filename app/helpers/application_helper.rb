module ApplicationHelper

  # checks if value is numeric
  # returns true for numeric values
  def numeric?(value)
    Float(value) != nil rescue false
  end
  # format a money object depending on current locale
  def money_to_currency(money)
    if money && numeric?(money)
      #number_to_currency(money.to_d, unit: money.currency.symbol)
      number_to_currency(money.to_d, unit: current_tenant.default_currency.symbol)
    else
      number_to_currency(Monetize.parse("0"))
    end
  end

  # Creates a nav_item including a link, but only if you have the right to read this class!
  # target: The name of the path. for untis_path, this would be :units
  # model_class: If the path's name does not match your Models name, you have to specify it.
  def nav_item(target, model_class = nil)
    model_class ||= target.to_s.classify.constantize
    if can? :read, model_class
      content_tag :li do
        link_to target do
          if block_given?
            yield
          else
            t(target)
          end
        end
      end
    end
  end

  def check_button(value)
    icon_class = value ? 'fa-check' : 'fa-times'
    content_tag :span do
      content_tag :i, class: ['fa', icon_class] do
        yield if block_given?
      end
    end
  end

  # tells the user the feature isn't activated or whatever message you yield
  def feature_notice(feature)
    if cannot? :access, feature
      content_tag :div, class: %w(alert alert-info) do
        if block_given?
          yield
        else
          t(:feature_not_activated)
        end
      end
    end
  end

  # for setup (currently only stripe requires setup, invoices don't)
  def register_plan_button(paymentplan)
    link_to register_payment_path(paymentplan), style: "width: 100%;" do
      content_tag :button, class: %W(button btn btn-lg #{paymentplan.recommended ? 'btn-success' : 'btn-primary'}), style: "width: 80%;" do
        [
          t("continue_with_payment"),
          number_to_currency(paymentplan.price / 100) + " / " + t("cycle.#{paymentplan.cycle}")
        ].join(tag(:br)).html_safe
      end
    end
  end
end
