namespace :wc do
  desc "Append street_no to street. Drop field street_no on the next step"
  task :append_street_no_to_street => :environment do

    Crm::ContactAddress.find_each do |contact_address|
      unless contact_address.street.blank?
        unless contact_address.street_no.blank?
          contact_address.street = contact_address.street + ' ' + contact_address.street_no.to_s
          contact_address.save!
        end
      end
    end

  end
end
