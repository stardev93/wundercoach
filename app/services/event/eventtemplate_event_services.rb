# Services for Eventtemplate to events

class EventtemplateEventServices

  # initialize with eventtemplate object
  def initialize

  end

  # copy attribute_list attributes to events of subevents
  def propagate_attributes(eventtemplate, attribute_arr)
    
    @eventtemplate = eventtemplate
    @attribute_arr = attribute_arr

    @eventtemplate.events.each do |event|

      if @attribute_arr['copy_name']
        event.name = @eventtemplate.name
        event.slug = nil
      end

      if @attribute_arr['copy_shortdescription']
        event.shortdescription = @eventtemplate.shortdescription
      end

      if @attribute_arr['copy_longdescription']
        event.longdescription = @eventtemplate.longdescription
      end

      if @attribute_arr['copy_bottom_text']
        event.bottom_text = @eventtemplate.bottom_text
      end

      # the price of the event
      if @attribute_arr['copy_full_price_cents']
        event.full_price = @eventtemplate.full_price
      end

      # the flag if early signup pricing is allowed
      # activate when eventtemplates allow for offset (not absolute dates) for field early_signup_deadline
      # if @attribute_arr['copy_early_signup_pricing']
      #   event.early_signup_pricing = @eventtemplate.early_signup_pricing
      #   event.save
      # end

      # the early signup price itself
      if @attribute_arr['copy_price_early_signup_cents'] && event.early_signup_pricing
        event.price_early_signup_cents = @eventtemplate.price_early_signup_cents
      end
      # save all changes
      event.save

    end

    return @eventtemplate
  end

end
