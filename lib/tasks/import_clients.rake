namespace :wc do
  desc "Create helper table content"
  task import_clients: :environment do
    ActsAsTenant.with_tenant(Account.find(1)) do
      imports = [
        {
          event: Event.find_by_slug('import-deutschland'),
          file: "misc/Coachingklienten/Tabelle1-Tabelle 1.csv",
          country: 'DE'
        }, {
          event: Event.find_by_slug('import-osterreich'),
          file: "misc/Coachingklienten/Tabelle2-Tabelle 1.csv",
          country: 'AT'
        }, {
          event: Event.find_by_slug('import-schweiz'),
          file: "misc/Coachingklienten/Tabelle3-Tabelle 1.csv",
          country: 'CH'
        }, {
          event: Event.find_by_slug('import-sonstige'),
          file: "misc/Coachingklienten/Tabelle4-Tabelle 1.csv",
          country: 'DE'
        }
      ]
      imports.each do |import_data|
        puts "importing #{import_data[:file]}"
        clients = CSV.read(import_data[:file], col_sep: ';')
        client_data = clients.map do |client_arr|
          {
            paymentmethod_id: 4,
            product: import_data[:event],
            eventbookings: [
              Eventbooking.new({
                event: import_data[:event],
                eventbookingstatus_id: 2,
                booking_date: Time.now,
                address: Address.new({
                  firstname: client_arr[0],
                  lastname: client_arr[1],
                  street: client_arr[2],
                  zip: client_arr[3],
                  city: client_arr[4],
                  telephone: client_arr[5],
                  email: client_arr[6],
                  gender: 'female',
                  country: import_data[:country]
                })
              })
            ]
          }
        end
        Order.create!(client_data)
      end
    end
  end
end
