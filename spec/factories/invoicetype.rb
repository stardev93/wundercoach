FactoryGirl.define do
  factory :invoice_type, class: "Billing::Invoicetype" do
    trait :invoice do
        key 'invoice'
    end
  end
end
