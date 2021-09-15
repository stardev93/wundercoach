FactoryGirl.define do
  factory :eventbookingstatus do
    trait :new do
			key 'new'
			css_class 'primary'
    end

    trait :confirmed do
			key 'confirmed'
			css_class 'success'
    end

    trait :waiting do
			key 'waiting'
			css_class 'info'
		end

		trait :waitinglist do
			key 'waitinglist'
			css_class 'warning'
		end

		trait :cancelled do
			key 'cancelled'
			css_class 'default'
    end
  end
end
