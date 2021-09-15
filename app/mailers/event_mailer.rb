# used for sending event and eventtemplate related mails.
# uses send_composed_mail from CustomerMailer
# Required mailer: wundercoach standard mailer OR custom if is setup
#
# sent from
# app/controllers/eventbookings_controller.rb
# app/controllers/events_controller.rb
# app/models/event_handler.rb
# app/models/eventbooking.rb
# app/models/order.rb
class EventMailer < CustomerMailer
end
