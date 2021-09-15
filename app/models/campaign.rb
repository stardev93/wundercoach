# represents a campaign in a third party crm tool
class Campaign < ActiveRecord::Base
  acts_as_tenant(:account)
  has_and_belongs_to_many :target_groups
  has_and_belongs_to_many :eventbookings, autosave: true

  def to_s
    name
  end

  # checks if campagin has been synced to mailchimp
  def synced?
    mailchimp_id.present?
  end

  # checks if campaign can be synced to mailchimp
  def syncable?
    !(target_groups.empty? || synced?)
  end

  # return all email addresses of campaign's recipients.
  # this list may vary before syncing, but is frozen afterwards
  def email_addresses
    if synced?
      eventbookings.pluck(:email).uniq
    else
      target_groups.map(&:email_addresses).flatten.uniq
    end
  end

  # number of recipients of this campaign
  def participant_count
    email_addresses.length
  end

  # executes the sync to mailchimp.
  # can only be executed once
  def sync!
    raise 'You cannot sync!' unless syncable?
    @api_key = account.mailchimp.api_key
    @list_id = account.mailchimp.list_id
    account.mailchimp.sync_from_wundercoach_to_mailchimp
    # sync should complete before making segment,
    # otherwise we might get a mailchimp error
    # in future versions, this should be handled by checking the batch status
    # and running the sync via delayed_job
    sleep(5)
    segment_id = create_segment!
    create_campaign! segment_id
  end

  private

  # get all Eventbookings by target_groups
  def participants
    ids = target_groups.map(&:participant_ids).flatten.uniq
    Eventbooking.where(id: ids)
  end

  # creates a mailchimp-segment for the campaign
  def create_segment!
    gibbon = Gibbon::Request.new(api_key: @api_key)
    response = gibbon.lists(@list_id).segments.create(body: {
      name: "Segment for Campaign #{id}",
      static_segment: email_addresses
    })
    eventbookings << participants
    response['id']
  end

  # creates a mailchimp-campaign. required segment can be created via create_segment!
  # saves the campaign if successful
  def create_campaign!(segment_id)
    gibbon = Gibbon::Request.new(api_key: @api_key)
    settings = {
      subject_line: name,
      title:        name,
      from_name:    account.email,
      reply_to:     account.email
    }
    recipients = {
      list_id: @list_id,
      segment_opts: {
        saved_segment_id: segment_id
      }
    }
    body = {
      type: 'regular',
      recipients: recipients,
      settings: settings
    }
    response = gibbon.campaigns.create(body: body)
    update!(mailchimp_id: response['id'])
  end

  # documentation

  # :attr_accessor: name
  # Accessor for the campaign's name
end
