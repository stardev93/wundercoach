FactoryGirl.define do
  factory :order do
    status { 1 }
    currency { 'BRL'}

    transient do
      free { false }
    end

    transient do
      generate_invoice { false }
    end

    before(:create) do |order, evaluator|
      if evaluator.free
        order.product = create(:event, account_id: order.account_id)
      else
        order.product = create(:event, :paid, account_id: order.account_id, generate_invoice: evaluator.generate_invoice)
      end
    end

    trait :payment_chosen do
      status 2
    end

    trait :cc_payment_method do
      paymentmethod { create(:paymentmethod, :cc) }
    end

    trait :bank_transfer_payment_method do
      paymentmethod { create(:paymentmethod, :bank_transfer) }
    end

    trait :vorkasse_payment_method do
      paymentmethod { create(:paymentmethod, :vorkasse) }
    end

    trait :gocardless_payment_method do
      paymentmethod { create(:paymentmethod, :direct_debit) }
    end

    trait :gocardless_redirect_flow_id do
      gocardless_redirect_flow_id "1654762"
    end
  end
end
