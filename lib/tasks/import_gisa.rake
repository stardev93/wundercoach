require 'csv'

namespace :wc do
  desc "Import faq from csv"

  task importgisa: :environment do
    Crm::ContactTagging.delete_all
    Crm::ContactTag.delete_all
    Crm::ContactAddress.delete_all
    Crm::ContactDetail.delete_all
    Crm::Contact.delete_all



    filename = File.join Rails.root, "misc/gisa-import.csv"
    counter = 0
    account_id = 1
    # CSV.foreach(filename) do |row|
    clients = CSV.read(filename, col_sep: ';')

    puts 'Importing ContactTags for account Gisa-Marburg...'
    client_data = clients.map do |client_arr|
      tagname = client_arr[14]
      begin
        tag = Crm::ContactTag.where(account_id: account_id, name: tagname).first_or_create
        #create!(account_id: account_id, name: tagname)
        #Contact.where(survey_id: survey,voter_id: voter).first_or_create
      rescue ActiveRecord::RecordNotUnique => e
        # ignore exisiting
      end
    end

    puts 'Importing Contacts for account Gisa-Marburg...'
    client_data = clients.map do |client_arr|

      firma = client_arr[6]
      type = "#{firma.blank? ? 'Person' : 'Company'}"
      gender = (client_arr[3].to_s == 'Frau' ? 'female' : 'male') unless client_arr[3].blank?
      lastname = (client_arr[5].to_s.blank? ? '?' : client_arr[5])
      firstname = client_arr[4].to_s
      debitorennummer = client_arr[2].to_s
      bereich = client_arr[10]
      tag = Crm::ContactTag.find_by(name: client_arr[14])

      contact = Crm::Contact.create!(account_id: account_id, type: type, name: (client_arr[6].blank? ? firstname.to_s+' '+lastname.to_s : client_arr[6]), name2: bereich, lastname: lastname, firstname: firstname, gender: gender, account_receivable_no: debitorennummer)

      Crm::ContactTagging.create!(account_id: account_id, contact_id: contact.id, contact_tag_id: tag.id) unless tag.nil?

      has_person = (type == 'Company' && !client_arr[5].to_s.blank?)
      if has_person
        puts 'ID:'+contact.id.to_s
        puts firma
        puts lastname
        puts firstname
        puts ' '
        Crm::Contact.create!(account_id: account_id, type: 'Person', name: firstname.to_s+' '+lastname.to_s, lastname: lastname, firstname: firstname, gender: gender, contact_id: contact.id)
      end

      has_address = !client_arr[9].blank?
      if has_address
        street = client_arr[7].rpartition(' ').first unless client_arr[7].blank?
        street_no = client_arr[7].rpartition(' ').last unless client_arr[7].blank?
        zip = client_arr[8]
        city = client_arr[9]
        country = '83'
        #puts street + ' ' + street_no  unless client_arr[7].blank?
        Crm::ContactAddress.create!(account_id: account_id, contact_id: contact.id, street: street, street_no: street_no, zip: zip, city: city, country: country, is_primary: true, address_type: 'billing_address')
      end

      has_phone = !client_arr[11].blank?
      if has_phone
        phone = client_arr[11]
        puts phone
        Crm::ContactDetail.create!(account_id: account_id, contact_id: contact.id, detail_value: phone, detail_type: 'work_phone')
      end

      has_mobile = !client_arr[12].blank?
      if has_mobile
        mobile = client_arr[12]
        puts mobile
        Crm::ContactDetail.create!(account_id: account_id, contact_id: contact.id, detail_value: mobile, detail_type: 'mobile')
      end

      has_email = !client_arr[13].blank?
      if has_email
        email = client_arr[13]
        puts email
        Crm::ContactDetail.create!(account_id: account_id, contact_id: contact.id, detail_value: email, detail_type: 'email')
      end

    end
  end
end
