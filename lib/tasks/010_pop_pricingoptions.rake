namespace :wc do
  desc "Create pricingoptionssets for each account"
  task :pop_pricingoptions => :environment do
    require 'populator'
    require 'faker'

    Coach.delete_all
    puts 'Populating pricingoptionssets for each account'

    Faker::Config.locale = 'de'

    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      i = account.id

      Product::Pricingset.populate 1 do |pricingoptionsset|

        pricingoptionsset.account_id = account.id
        pricingoptionsset.name = 'Preisnachlass für Mitglieder'
        pricingoptionsset.description = 'Sind sie Mitglied im ADAC? Dann zahlen Sie 10% weniger.'
        pricingoptionsset.active = true

      end

      Product::Pricingset.find_each do |pricingset|
        Product::Pricingoption.create!(
          {
            account_id: i,
            pricingset_id: pricingset.id,
            name: 'Normal-Preis',
            comments: 'Diese Option gilt für Nicht-Mitglieder',
            hint_text: 'Ich zahle den Normalpreis',
            full_price_deduct_perc: 0,
            price_early_signup_deduct_perc: 0,
            position: 1,
            preset: true
          }
        )
        Product::Pricingoption.create!(
          {
            account_id: i,
            pricingset_id: pricingset.id,
            name: 'Preisnachlass 10% für Mitglieder',
            comments: 'Diese Option gilt für Mitglieder',
            hint_text: 'Ich bin ADAC-Mitglied',
            full_price_deduct_perc: 10,
            price_early_signup_deduct_perc: 10,
            position: 2,
            preset: false
          }
        )
      end

    end
    puts 'Done populating pricingoptionssets'
  end
end
