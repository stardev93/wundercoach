class Product::Pricingoption < ActiveRecord::Base
  acts_as_tenant(:account)
  acts_as_list scope: :pricingset

  before_save :enforce_unique_preset
  after_commit :enforce_first_preset, on: [ :create, :update ]

  belongs_to :account
  belongs_to :pricingset

  monetize :full_price_deduct_cents, with_model_currency: :currency, allow_nil: true
  monetize :price_early_signup_deduct_cents, with_model_currency: :currency, allow_nil: true

  scope :by_position, -> { order("position ASC") }
  scope :with_preset, -> { where("preset=true") }

  validates_with ProductPricingoptionValidator

  def to_s
    name
  end

  # return true if full_price_deduct_cents is > 0
  # else false if full_price_deduct_perc
  def is_absolute?
    !full_price_deduct_cents.nil?
  end

  # returns event.full_price_cents after deduction of absolute or percentage value
  def full_price(event)
    if is_absolute?
      # return the events full_price reduced by absolute reduction
      if full_price_deduct && event.full_price
        event.full_price - full_price_deduct
      else
        0
      end
    else
      # return the events full_price reduced by percentage reduction
      if full_price_deduct_perc && event.full_price
        event.full_price - (full_price_deduct_perc * event.full_price / 100)
      else
        0
      end
    end

  end

  # returns event.price_early_signup_cents after deduction of absolute or percentage value
  def price_early_signup(event)
    if is_absolute?
      # return the events full_price reduced by absolute reduction
      if price_early_signup_deduct_cents && event.price_early_signup
        event.price_early_signup - price_early_signup_deduct
      else
        0
      end
    else
      # return the events full_price reduced by percentage reduction
      if price_early_signup_deduct_perc && event.price_early_signup
        event.price_early_signup - (price_early_signup_deduct_perc * event.price_early_signup / 100)
      else
        0
      end
    end
  end

  # get the events current price for this option,
  # i.e. with or without early booking discount
  def price(event)
    # does early booking apply?
    if event.early_booking_price_applies?
      price_early_signup(event)
    else
      full_price(event)
    end
  end

  def price_cents(event)
    if event.early_booking_price_applies?
      price_early_signup(event).cents
    else
      full_price(event).cents
    end
  end

  # get the deduction for this option,
  # i.e. with or without early booking discount
  # and as percentage or absolute
  def deduction(event)
    # does early booking apply?
    if event.early_booking_price_applies?
      if is_absolute?
        price_early_signup_deduct
      else
        price_early_signup_deduct_perc
      end
    else
      if is_absolute?
        full_price_deduct
      else
        full_price_deduct_perc
      end
    end
  end

  def net_price(event)
    ProductCalculatePrice.new(price(event), event.vat, event.vat_included?).net_price
  end

  def gross_price(event)
    ProductCalculatePrice.new(price(event), event.vat, event.vat_included?).gross_price
  end

  def vat_sum(event)
    ProductCalculatePrice.new(price(event), event.vat, event.vat_included?).vat_sum
  end

  def vat_rate(event)
    ProductCalculatePrice.new(price(event), event.vat, event.vat_included?).vat_rate
  end

  # # return the full price with deduction, even if early_booking_applies
  # def full_price(event)
  #   ProductCalculatePrice.new(price(event), event.vat, event.vat_included?).vat_rate
  # end

  private

  def enforce_unique_preset
    if preset
      pricingset.pricingoptions.with_preset.where("id != ?", id).each do |pricingoption|
        pricingoption.preset = false
        pricingoption.save
      end
    end
  end

  def enforce_first_preset
    if !pricingset.pricingoptions.with_preset.any?
      self.update_column(:preset, true)
    end
  end
end
