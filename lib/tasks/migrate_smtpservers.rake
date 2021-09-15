namespace :wc do
  desc "Creating default SMTP-Servers for existing clients"
  task create_smtpservers: :environment do
    puts "Generating SMTP-Servers for #{Account.find_each.count} accounts"
    i=1
    Account.find_each do |account|
      puts " "
      puts "#{i}) Starting SMTP server setup for:"
      puts "#{(account.name.blank? ? 'No name given' : account.id.to_s + ' ' + account.name)}"
      if !account.smtpservers.exists?
        ActiveRecord::Base.transaction do
          begin
            Smtpserver.create!([
              {account: account, server: "mail.businesshosting24.com", port: "465", username: "go@wundercoach.net", password: "61d2c1Uk4", ssl: true, active: true, from_address: "go@wundercoach.net", from_name: account.name, replyto_address: account.email, key: "wundercoach_standard"},
              {account: account, server: account.domain, port: "567", username: account.email, password: "", ssl: true, active: false, from_address: account.email, from_name: account.name, replyto_address: account.email, key: "custom"}
            ])
            puts "done."
          rescue Exception => e
            ActiveRecord::Rollback
            puts "Error generating SMTP server: #{e}"
          end
        end
      else
        puts "SMTP-Servers already exist!"
      end
      i = i + 1
    end
  end
end
