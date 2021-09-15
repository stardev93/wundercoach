FactoryGirl.define do
  factory :booking do
    type "StripeBooking"
  end

  factory :stripe_booking do
    paymentplan Paymentplan.pro
  end

  factory :trial_booking do
    paymentplan Paymentplan.premium
    factory :expiring_trial_booking do
      is_current true
      valid_until -1.day.from_now
    end
  end

  factory :free_booking do
    paymentplan Paymentplan.free
  end

  factory :invoice_booking do
    paymentplan Paymentplan.pro
  end
end
