module Embedded
  # provides context for a widget based on an event
  # make the replacings for javascript event lists
  class EventSubeventDecorator < Draper::Decorator
    delegate_all
    attr_accessor :adpartner_id

    def context
      {
        'id' => object.id,
        'event_id' => object&.subevent&.id,
        'bottom_text' => object&.subevent&.bottom_text,
        'longdescription' => object&.subevent&.longdescription,
        'maxparticipants' => object&.subevent&.maxparticipants,
        'name' => object&.subevent&.name,
        'price' => object&.subevent&.price,
        'full_price' => object&.subevent&.full_price,
        'shortdescription' => object&.subevent&.shortdescription,
        'start_date' => object&.subevent&.decorate.start_date,
        'start_time' => object&.subevent&.decorate.start_time,
        'end_date' => object&.subevent&.decorate.end_date,
        'end_time' => object&.subevent&.decorate.end_time,
        'use_product_location' => object&.subevent&.use_product_location,
        'get_location' => object&.subevent&.get_location,
        'get_eventorganizer' => object&.subevent&.get_eventorganizer,
        'get_street' => object&.subevent&.get_street,
        'get_streetno' => object&.subevent&.get_streetno,
        'get_city' => object&.subevent&.get_city,
        'get_zip' => object&.subevent&.get_zip,
        'get_state' => object&.subevent&.get_state,
        'get_country' => object&.subevent&.get_country,
        'product_location' => object&.subevent&.product_location_id,
        'eventorganizer_name' => object&.subevent&.product_location&.eventorganizer_name,
        'location_name' => object&.subevent&.product_location&.location_name,
        'street_name' => object&.subevent&.product_location&.street,
        'zip_name' => object&.subevent&.product_location&.zip,
        'city_name' => object&.subevent&.product_location&.city,
        #'googlemapslocation' => object&.subevent&.get_google_maps_link,
        'location' => object&.subevent&.location,
        'city' => object&.subevent&.city,
        'state' => object&.subevent&.state,
        'country' => object&.subevent&.country,
        'eventorganizer' => object&.subevent&.eventorganizer,
        'street' => "#{object&.subevent&.street} #{object&.subevent&.streetno}",
        'zip' => object&.subevent&.zip,
        'coaches' => object&.subevent&.coaches.join('<br>'),
        'coach_list' => object&.subevent&.coaches.pluck(:lastname, :firstname, :homepage_url).join(','),
        'tags' => object&.subevent&.product_tags.pluck(:name).join(','),
        'remaining_seats' => object&.subevent&.seats_free,
        'account' => object&.subevent&.account.name,
        'type' => object&.subevent&.type,
        'eventtemplate_id' => object&.subevent&.eventtemplate_id,
        'early_booking_price_applies?' => object&.subevent&.early_booking_price_applies?,
        'eventtype' => object&.subevent&.eventtype.to_s
      }
    end
  end
end
