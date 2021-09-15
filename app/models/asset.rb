class Asset < ActiveRecord::Base
  acts_as_tenant(:account)

  set_callback :save, :before, :setup
  belongs_to :user
  belongs_to :event
  belongs_to :eventsession

  validates :asset, presence: true
  validates :asset,
            attachment_content_type: { content_type: ["image/jpeg", "image/png", "/\Aimage\/.*\Z/", "application/pdf"] },
            attachment_size: { less_than: 25.megabytes }

  has_attached_file :asset, styles: {
    thumb: ['100x100#', :png],
    square: ['200x200#', :png],
    medium: ['600x600>', :png]
  }

  def to_s
    name.present? ? name : asset_file_name
  end

  # get the size in MB
  def size_mb
    (asset_file_size.to_f / 1_000 / 1_024).round(2)
  end

  def icon
    case asset_content_type
    when 'image/png'
      'image.png'
    when 'application/pdf'
      'image.png'
    else
      'unknown.png'
    end
  end

  def setup
    self.name = asset_file_name if name.blank?
  end
end
