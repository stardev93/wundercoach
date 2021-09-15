# target groups fetch the campaign's participants using filters
class TargetGroup < ActiveRecord::Base
  acts_as_tenant(:account)
  has_and_belongs_to_many :filters
  has_and_belongs_to_many :campaigns

  def to_s
    name
  end

  def participants
    customers = Eventbooking.joins(:event, :address)
    filters.each do |filter|
      customers = customers.send(filter.scope_name, *filter.scope_params)
    end
    customers
  end

  # utility required by campaigns
  def participant_ids
    participants.pluck(:id)
  end

  def email_addresses
    participants.pluck(:email).uniq
  end

  def participant_count
    email_addresses.length
  end
end
