require "rails_helper"

RSpec.describe Account, type: :model, skip: true do
  it "is created with associated mailtemplates" do
    account = Account::Register.call({
      name: "Test Company",
      firstname: "Max",
      lastname: "Mustermann",
      creator: {
        email: "test1@test.com",
        password: "asdasdasd"
      }
    }, 'user.use_activation' => false)['model']
    expect(account.mailtemplates.count).to eq(Mailtemplate.system.count)
  end

  it "is created with associated accountpaymentmethods" do
    account = Account::Register.call({
      name: "Test Company",
      firstname: "Max",
      lastname: "Mustermann",
      creator: {
        email: "test1@test.com",
        password: "asdasdasd"
      }
    }, 'user.use_activation' => false)['model']
    expect(account.paymentmethods).to eq(Paymentmethod.where(key: %w(banktransfer vorkasse free)))
  end

  # pending "Test for new feature system"
  # it "can access features" do
  #   # account = Account.create!(email: "account@test.com")
  #   # ActsAsTenant.current_tenant = account
  #   # account.book_paymentplan! Paymentplan.find_by(key: "free-monthly")
  #   # user = User.create!(email: "user@test.com")
  #   # user.roles << Role.find_by(name: "user")
  #   # ability = Ability.new(user)
  #   # enabled_feature = account.paymentplan.features.first
  #   # disabled_feature = Feature.where.not(id: account.features.pluck(:id)).first
  #   #
  #   # expect(ability.can? :access, enabled_feature).to be true
  #   # expect(ability.can? :access, disabled_feature).to be false
  # end
end
