namespace :wc do
  desc 'Creates a custom enterprise paymentplan'
  task create_enterprise_plan: :environment do
    paymentplan = Paymentplan.new({
      name: 'Enterprise',
      comments: 'Uneingeschränkter Zugriff auf alle Funktionen',
      price: 39_000,
      cycle: 'monthly'
    })

    features = Feature.all.map {|feature| { feature: feature, paymentplan: paymentplan, fieldvalue: '1' } }
    Paymentplanfeature.create!(features)
  end
end
