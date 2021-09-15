class Mailchimp < ActiveRecord::Base
  acts_as_tenant :account

  validates :api_key, presence: true

  before_save :find_or_create_wundercoach_list

  # syncs customers using a batch upsert
  def sync_from_wundercoach_to_mailchimp
    require 'digest/md5'
    put_operation = {
      method: 'PUT'
    }
    customers = Eventbooking.subscribed
    customers = customers.recently_updated(last_sync) unless last_sync.nil?
    if customers.empty?
      Rails.logger.info 'no changes, no sync'
    else
      operations = customers.to_a.uniq(&:email).map do |eventbooking|
        put_operation.merge({
          path: "lists/#{list_id}/members/#{Digest::MD5.hexdigest(eventbooking.email.downcase)}",
          body: {
            email_address: eventbooking.email,
            status: 'subscribed',
            status_if_new: 'subscribed',
            merge_fields: {
              FNAME: eventbooking.firstname,
              LNAME: eventbooking.lastname
            }
          }.to_json
        })
      end
      Rails.logger.info operations
      execute_batch_request(operations)
    end
  end

  private

  def execute_batch_request(operations)
    result = request.batches.create(body: {
      operations: operations
    })
    Rails.logger.info result
  end

  def find_or_create_wundercoach_list
    return true unless list_id.blank?
    self.list_id = find_wundercoach_list
    self.list_id = create_wundercoach_list if list_id.blank?
    list_id.present?
  end

  # Finds first list called "Wundercoach", if it exists
  def find_wundercoach_list
    response = request.lists.retrieve(params: { 'fields' => 'lists.id,lists.name' })
    wundercoach_list = response['lists'].detect {|list| list['name'] == 'Wundercoach' }
    wundercoach_list['id'] if wundercoach_list
  end

  # creates the list called "Wundercoach" which we'll use in mailchimp
  def create_wundercoach_list
    response = request.lists.create({
      body: {
        name: 'Wundercoach',
        permission_reminder: 'You booked an event at wundercoach.net',
        use_archive_bar: false,
        campaign_defaults: {
          from_name: account.name,
          from_email: account.email,
          language: 'de',
          subject: 'Newsletter'
        },
        contact: account.mailchimp_contact_data,
        email_type_option: false,
        visibility: 'prv'
      }
    })
    response['id']
  end

  def request
    Gibbon::Request.new(api_key: api_key)
  end
end
