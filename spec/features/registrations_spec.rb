require 'rails_helper'

RSpec.feature "Registrations", type: :feature, skip: true do
  scenario "Customer signs up at Wundercoach" do
    visit "/de/register/new"

    fill_in "account_name", with: "Test Company"
    fill_in "account_firstname", with: "Max"
    fill_in "account_lastname", with: "Mustermann"
    fill_in "account_creator_attributes_email", with: "stefan.luetge@siliconplanet.com"
    fill_in "account_creator_attributes_password", with: "asdasdasd"
    check "account_terms_of_service"
    click_button "Jetzt kostenlos ausprobieren"

    expect(page).to have_text("Ihr Wundercoach-Konto wurde erstellt.")
  end
end
