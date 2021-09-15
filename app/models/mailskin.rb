class Mailskin < ActiveRecord::Base
  acts_as_tenant(:account)

  has_many :mailtemplates, autosave: true
  has_many :mailskinassets, dependent: :destroy

  validates :key, :name, :htmlbody, presence: true
  validates :key, uniqueness: { scope: :account }

  scope :system, -> { where(account: nil) }

  translates :name

  def to_s
    name
  end

  # render html sourcecode with images
  def render(content = 'No template provided')
    # get Nokogiri object with html source
    html = Nokogiri::HTML(htmlbody)

    # pick image tags from source and inject the right images
    mailskinassets.each do |mailskinasset|
      html.css('img').each do |image|
        # do we have the filename of our mailskinasset in the source attribute?
        if image.attributes['src'].value.to_s.include? mailskinasset.mailskinasset_file_name
          # replace he whole source with correct url
          image.attributes['src'].value = mailskinasset.absolute_asset_url.to_s
        end
      end
    end
    html.to_s.gsub('{yield}', content)
  end
end
