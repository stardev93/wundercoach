class Eventsession < ActiveRecord::Base
  before_save :prepare_record
  before_create :generate_sessioncode, unless: :token?

  belongs_to :durationunit
  belongs_to :event
  has_many :assets
  has_many :eventsessionbookings, :dependent => :destroy

  validates :event, :name, :durationunit, presence: true
  validates :start_date, :end_date, presence: true, unless: :belongs_to_template?

  acts_as_list scope: :event

  scope :planned, -> { where("status LIKE ?", "planned").order('start_date') }
  scope :unplanned, -> { where("status LIKE ?", "unplanned").order('start_date') }
  default_scope { order(position: :asc) }

  def to_s
    name
  end

  def duration
    result = end_date - start_date

    if durationunit.key == "h"
      result = result * 24
    end

    result.to_i
  end

  def getname
    return :day
  end

  def generate_sessioncode
    self.token = SecureRandom.uuid
  end

  # return true if parent event is a template
  def belongs_to_template?
    return false
    # outdated due to model change.
    # eventtemplates are object of own class
    # eventsessions cannot belong to an event with is_template == true anymore
    # return self.event.is_template
  end

  private
    def prepare_record
      self.position = self.event.getnextnumber
      self.end_date = self.start_date
      #self.start_time = self.start_date + 8.hours
      #self.end_time = "17:00:00"
    end

end
