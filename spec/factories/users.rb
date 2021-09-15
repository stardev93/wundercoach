FactoryGirl.define do
  factory :user do
    lastname "Mustermann"
    firstname "Max"
    gender "male"
    tel "01234567889"
    sequence(:email) {|n| "test#{n}@test.com" }
    zip 11_111
    city "Hamburg"
    street "Henriettenweg"
    street_no 4
    country "DE"
    password "test01"

    trait :with_account do
      after(:create) { |user| user.account = create(:account, users: [user]) }
    end

    trait :activated do
      after(:create) { |user| user.activate! }
    end

    trait :affiliate do
      after(:create) { |user| user.roles << create(:role, :affiliate) }
    end

    trait :admin do
      after(:create) { |user| user.roles << create(:role, :admin) }
    end

    after(:create) do |user|
      # default role
      user.roles << create(:role, :user)

      # default account
       user.account = create(:account, users: [user])
    end
  end
end
