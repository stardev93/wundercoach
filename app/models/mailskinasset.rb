class Mailskinasset < ActiveRecord::Base
  acts_as_tenant(:account)

  belongs_to :mailskin

  validates :mailskinasset, presence: true
  validates :mailskinasset,
            attachment_content_type: { content_type: ['image/jpeg', 'image/png', "/\Aimage\/.*\Z/"] },
            attachment_size: { less_than: 1.megabytes }

  has_attached_file :mailskinasset, styles: {
    thumb: ['50x50#', :png]
  }

  def to_s
    mailskinasset_file_name || ''
  end

  def absolute_asset_url
    URI.join(ActionMailer::Base.default_url_options[:host], mailskinasset.url)
  end

  # FIXME: This is most certainly going to crash. Not all assets are in 000.
  def get_path
    "system/mailskinassets/mailskinassets/000/#{id}/original/"
  end
end
