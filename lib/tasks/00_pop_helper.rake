namespace :wc do
  desc "Create helper table content"
  task pop_helper: :environment do
    ActsAsTenant.with_tenant(Account.find(1)) do
      Coach.create!([
        {lastname: "Coach", firstname: "Carla", tel: "+49 40 987 654 321", gender: "female", email: "carla.coach@wundercoach.net", account_id: 1},
        {lastname: "Mustercoach", firstname: "Max", tel: "+49 40 123 456 789", gender: "male", email: "max.mustercoach@wundercoach.net", account_id: 1}
      ])
      puts 'Coaches generated. Task done.'
    end
  end
end
