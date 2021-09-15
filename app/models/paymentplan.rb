class Paymentplan < ActiveRecord::Base
  # I refer to changing paymentplans as a transition. The Transition Struct
  # is used to verify if such a transition is possible, and will offer an
  # error message if it is not.
  Transition = Struct.new(:possible?, :error_message)

  include Comparable

  FREE_PLANS = %w(free free-monthly free-yearly).freeze

  has_many :features, through: :paymentplanfeatures, dependent: :destroy
  has_many :paymentplanfeatures
  has_many :accounts
  has_many :bookings

  belongs_to :appversion

  scope :current_plans, -> { joins(:appversion).merge(Appversion.current) }
  scope :free, -> { current_plans.find_by(key: "free-monthly") }
  scope :pro, -> { current_plans.find_by(key: "pro-monthly") }
  scope :premium, -> { current_plans.find_by(key: "premium-monthly") }

  default_scope -> { order(sortorder: :asc) }

  translates :name, :comments

  def to_s
    name
  end

  def gross_price
    gross_price_cents.to_d / 100
  end

  def net_price
    net_price_cents.to_d / 100
  end

  def gross_price_cents
    if is_gross
      price
    else
      (price * vat_factor).round
    end
  end

  def net_price_cents
    if is_gross
      (price / vat_factor).round
    else
      price
    end
  end

  def free?
    FREE_PLANS.include? key
  end

  # returns an object that indicates if the transition is possbile,
  # along with a message that tells you why the transition is impossible
  def self.transition(current_plan, new_plan)
    if current_plan.id == new_plan.id
      Transition.new(false, :current_plan_error)
    elsif current_plan.cycle == "yearly" && new_plan.cycle == "monthly" && new_plan > current_plan
      # Pro Yearly => Pro monthly is not possible
      Transition.new(false, :pro_yearly_to_premium_monthly_not_possible)
    else
      # Allow without error message
      Transition.new(true, "")
    end
  end

  # compare plans. Returns 1 if plan 1 is better, 0 if equal, -1 if plan2 is better
  def <=>(other)
    return 0 if key_without_cycle == other.key_without_cycle
    return 1 if key_without_cycle == "enterprise"
    case [key_without_cycle, other.key_without_cycle]
    when %w(premium pro), %w(premium free), %w(pro free)
      1
    when %w(pro premium), %w(free premium), %w(free pro)
      -1
    end
  end

  def cycle_in_days
    if cycle == "monthly"
      1.months
    elsif cycle == "yearly"
      1.years
    end
  end

  # return the default plan
  def self.default_plan
    Paymentplan.current_plans.find_by(key: "free-monthly")
  end

  # replace with some field dedicated to ordering paymentplans
  def key_without_cycle
    key.match(/\A[^-]*/).to_s
  end

  private

  def vat_factor
    @@vat_factor ||= Vat.find_by(key: 'regular_vat').value + 1
  end
end
