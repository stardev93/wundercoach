FactoryGirl.define do
  factory :account do
    sequence(:name) {|n| "Test Account-#{n}" }
    sequence(:email) {|n| "test#{n}@test.com" }
    sequence(:token) {|n| "asdfasdfasdf-#{n}asdfasdf234-234234sdf'" }
    sequence(:gocardless_access_token) {|n| "asdfasdfasdf-#{n}asdfasdf234-234234sdf'" }
    sequence(:subdomain) {|n| "#{10_000 + n}" }

    after(:build) do |account|
      create(:paymentplan, :pro)
      create(:paymentmethod, :vorkasse)
      account.bookings << create(:booking, is_current: true, paymentplan: Paymentplan.pro, account: account)
      account.eventtypes << create(:eventtype, account: account)
      account.accountstatus = Accountstatus.find_by key: "active"
    end

    after(:create) do |account|
      Paymentmethod.where(key: %w(banktransfer vorkasse free)).each do |method|
        account.accountpaymentmethods << Accountpaymentmethod.new({
          paymentmethod: method,
          is_active: true
        })
      end
    end

    factory :account_with_events do
      transient do
        events_count 5
      end
      after(:create) do |account, evaluator|
        create_list(:standard_event, evaluator.events_count, account: account)
      end
    end
  end
end
