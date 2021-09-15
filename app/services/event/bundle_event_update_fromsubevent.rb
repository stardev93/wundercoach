# Update BundleEvent with settings from subevent
# return BundleEvent.new(bundleevent, event).perform

class BundleEventUpdateFromSubevent

  # initialize with invoice object to send an invoice
  def initialize(bundle_event, event)
    @bundle_event = bundle_event
    @event = event
  end

  def perform

    if @bundle_event.subevents.any?
      # get earliest start_date from subevents
      first_start_date = @bundle_event.subevents.by_date.first.subevent
      @bundle_event.start_date = first_start_date.start_date

      # get latest end_date from subevents
      last_end_date = @bundle_event.subevents.by_date_desc.first.subevent
      @bundle_event.end_date = last_end_date.end_date

      # set the maxparticipants to min value from all subevents to prevent overbooking
      min_maxparticipants = @bundle_event.subevents.by_maxparticipants.first.subevent
      @bundle_event.maxparticipants = min_maxparticipants.maxparticipants

      # set the latest signup date to
      min_latest_signup_date = @bundle_event.subevents.by_latest_signup_date.first.subevent
      @bundle_event.latest_signup_date = min_latest_signup_date.latest_signup_date
    else
      @bundle_event.start_date = nil
      @bundle_event.end_date = nil
      @bundle_event.maxparticipants = 0
      @bundle_event.max_additional_participants = 0
      @bundle_event.latest_signup_date = nil
    end

    @bundle_event.latest_signup_date = nil
    @bundle_event.save!

    return @bundle_event
  end

end
