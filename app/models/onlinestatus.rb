class Onlinestatus < ActiveRecord::Base
  #default_scope -> { order('position') }

  scope :by_key, ->(key) { where(key: key) }
  scope :offline,     -> { by_key('offline') }
  scope :online,      -> { by_key('online') }
  scope :bundle_only, -> { by_key('bundle_only') }

  # Not all onlinestatuses make sense for a bundle. this scope hides some states
  # from bundles
  scope :available_for_bundles, -> { by_key(%w(online offline)) }
  # shall the event be shown in the bundle?
  scope :show_in_bundle, -> { by_key(%w(online bundle_only)) }

  translates :name, :description
  def to_s
    name
  end
end
