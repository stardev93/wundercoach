FactoryGirl.define do
  factory :coach do
    firstname { Faker::Name.name }
  end
end
