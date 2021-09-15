namespace :wc do
  desc "Creating default SMTP-Server"
  task pop_smtpservers: :environment do
    Account.find_each do |account|
      ActsAsTenant.with_tenant(account) do
        Smtpserver.delete_all
        # Smtpserver.create!([
        #   {server: "smtp.sendgrid.com", port: "567", username: "go@wundercoach.net", password: "passwordhere", ssl: true, active: true, from_address: "go@wundercoach.net", from_name: nil, replyto_address: nil, account_id: 1, key: "wundercoach_standard"},
        #   {server: account.domain, port: "567", username: account.email, password: "", ssl: true, active: false, from_address: account.email, from_name: account.name, replyto_address: account.email, account_id: 1, key: "custom"}
        # ])
        Smtpserver.create([
          {account_id: account.id, key: 'wundercoach_standard', server: "mail.businesshosting24.com", port: "465", username: "go@wundercoach.net", password: "61d2c1Uk4", ssl: true, active: true, from_address: "go@wundercoach.net", from_name: account.name, replyto_address: account.email},
          {account_id: account.id, key: 'custom', server: "", port: "", username: "", password: "", ssl: true, active: false, from_address: account.email, from_name: account.name, replyto_address: account.email}
          ])
        puts 'SMTP-Servers generated. Task done.'
      end
    end
  end
end
