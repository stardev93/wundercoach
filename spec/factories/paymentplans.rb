FactoryGirl.define do
  factory :paymentplan do
    trait :pro do
        key 'pro-monthly'
        appversion
    end

    trait :premium do
        key 'premium-monthly'
        appversion
    end
  end
end
