namespace :wc do
  desc "Create demo contacts for all accounts"
  task :pop_contacts => :environment do
    require 'populator'
    require 'faker'

    Crm::ContactTagging.delete_all
    Crm::ContactTag.delete_all
    # Crm::ContactAddress.delete_all
    # Crm::ContactDetail.delete_all
    # Crm::Contact.delete_all

    puts 'Creating Contacts, ContactTags, ContactAddresses and ContactDetails for all accounts...'
    Account.find_each do |account|
      ActsAsTenant.current_tenant = account
      puts 'Account: ' + account.id.to_s + ' ' + account.name
      ct = Crm::ContactTag.new({
        account: account,
        name: 'Kunde'
      })
      puts ct
      ct.save!
      ct = Crm::ContactTag.new({
        account: account,
        name: 'Lead'
      })
      puts ct
      ct.save!
      ct = Crm::ContactTag.new({
        account: account,
        name: 'Interessent'
      })
      puts ct
      ct.save!
      puts '3 nice ContactTags generated...'

      Faker::Config.random = Random.new(20)
      20.times do |i|
        Crm::ContactTag.create!({
          account: account,
          name: Faker::Company.unique.buzzword
        })
      end
      puts 'Another 20 random ContactTags generated...'

      20.times do |i|
        Crm::Contact.create!({
          account: account,
          type: 'Company',
          name: Faker::Company.name,
          name2: Faker::Company.catch_phrase,
          firstname: Faker::Name.first_name,
          vat_id: Faker::Company.ein,
          register: Faker::Address.city,
          register_code: Faker::Company.duns_number,
          account_receivable_no: Faker::Company.ein,
          contact_no: Faker::Company.ein,
          comments: Faker::Lorem.paragraph
        })
        Crm::Contact.create!({
          account: account,
          type: 'Person',
          lastname: Faker::Name.last_name,
          firstname: Faker::Name.female_first_name,
          name: "#{:lastname}, #{:firstname}",
          gender: 'female',
          vat_id: Faker::Company.ein,
          register: Faker::Address.city,
          register_code: Faker::Company.duns_number,
          contact_no: Faker::Company.ein,
          account_receivable_no: Faker::Company.ein
        })
        Crm::Contact.create!({
          account: account,
          type: 'Person',
          lastname: Faker::Name.last_name,
          firstname: Faker::Name.male_first_name,
          name: "#{:lastname}, #{:firstname}",
          gender: 'male',
          vat_id: Faker::Company.ein,
          register: Faker::Address.city,
          contact_no: Faker::Company.ein,
          register_code: Faker::Company.duns_number
        })
        # puts i.to_s+' Contact generated...'
      end


    end

    # assign persons to company contacts
    Crm::Contact.companies.find_each do |contact|
      Crm::Contact.create!({
        account: contact.account,
        company: contact,
        type: 'Person',
        lastname: Faker::Name.last_name,
        firstname: Faker::Name.female_first_name,
        name: "#{:lastname}, #{:firstname}",
        gender: 'female',
        vat_id: Faker::Company.ein,
        register: Faker::Address.city,
        register_code: Faker::Company.duns_number
      })
      Crm::Contact.create!({
        account: contact.account,
        company: contact,
        type: 'Person',
        lastname: Faker::Name.last_name,
        firstname: Faker::Name.male_first_name,
        name: "#{:lastname}, #{:firstname}",
        gender: 'male',
        vat_id: Faker::Company.ein,
        register: Faker::Address.city,
        register_code: Faker::Company.duns_number
      })
    end

    Person.find_each do |person|
      person.name = "#{person.lastname}, #{person.firstname}"
      person.save
    end

    Crm::Contact.find_each do |contact|
      3.times do |i|
        Crm::ContactAddress.create!({
          account: contact.account,
          contact: contact,
          street: Faker::Address.street_name + ' ' + Faker::Address.building_number,
          zip: Faker::Address.zip,
          city: Faker::Address.city,
          country: Faker::Address.country,
          address_type: %w(delivery_address billing_address other_address).sample
        })
        puts i.to_s + ' Address added for: ' + ' ' + contact.name + ' ' + contact.type.to_s
      end
    end

    Crm::Contact.find_each do |contact|
      contact_address = contact.contact_addresses.first
      contact_address.is_primary = true
      contact_address.save
    end

    Crm::Contact.find_each do |contact|
      1.times do |i|
        Crm::ContactDetail.create!({
          account: contact.account,
          contact: contact,
          detail_value: Faker::Internet.domain_name,
          detail_type: "website"
        })
        Crm::ContactDetail.create!({
          account: contact.account,
          contact: contact,
          detail_value: Faker::Internet.email,
          detail_type: "email"
        })
        Crm::ContactDetail.create!({
          account: contact.account,
          contact: contact,
          detail_value: Faker::PhoneNumber.phone_number,
          detail_type: "work_phone"
        })
        Crm::ContactDetail.create!({
          account: contact.account,
          contact: contact,
          detail_value: Faker::PhoneNumber.phone_number,
          detail_type: "mobile_phone"
        })
        # puts '3 ContactDetail added...'
      end
    end
    
    Crm::Contact.all.find_each do |contact|
      Crm::ContactTagging.create!({
        contact_tag_id: Crm::ContactTag.all.sample.id,
        contact_id: contact.id
      })
      Crm::ContactTagging.create!({
        contact_tag_id: Crm::ContactTag.all.sample.id,
        contact_id: contact.id
      })
    end
    puts 'Done.'
  end
end
