FactoryGirl.define do
  factory :role do
    trait :user do
        name 'user'
    end

    trait :admin do
        name 'admin'
    end

    trait :client do
        name 'client'
    end

    trait :affiliate do
        name 'affiliate'
    end
  end
end
