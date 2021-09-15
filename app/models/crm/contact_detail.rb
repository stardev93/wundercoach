class Crm::ContactDetail < ActiveRecord::Base
  belongs_to :account
  belongs_to :contact

  self.table_name = "contact_details"

  validates :detail_value, presence: true

  scope :email, -> { where(detail_type: 'email') }
  scope :private_phone, -> { where(detail_type: 'private_phone') }
  scope :work_phone, -> { where(detail_type: 'work_phone') }
  scope :mobile_phone, -> { where(detail_type: 'mobile_phone') }
  scope :website, -> { where(detail_type: 'website') }
  scope :other_detail, -> { where(detail_type: 'other_detail') }

  def to_s
    detail_value
  end

end
