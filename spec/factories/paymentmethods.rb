FactoryGirl.define do
  factory :paymentmethod do
    trait :vorkasse do
      name 'vorkasse'
      key 'vorkasse'
    end

    trait :free do
      name 'free'
      key 'free'
    end

    trait :bank_transfer do
      name 'bank transfer'
      key 'bank_transfer'
    end

    trait :cc do
      name 'cc'
      key 'cc'
    end

    trait :direct_debit do
      name 'direct_debit'
      key 'direct_debit'
    end
  end
end
