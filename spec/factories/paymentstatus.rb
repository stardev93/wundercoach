FactoryGirl.define do
  factory :payment_status, class: "Paymentstatus" do
    trait :paid do
      key 'paid'
    end

    trait :open do
      key 'open'
    end
  end
end
