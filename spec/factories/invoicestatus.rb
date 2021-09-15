FactoryGirl.define do
  factory :invoice_status, class: "Billing::Invoicestatus" do
    trait :new do
        key 'new'
    end
  end
end
