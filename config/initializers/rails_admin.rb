require_relative "../../lib/rails_admin/switch_user.rb"

RailsAdmin.config do |config|
  ## == Sorcery ==
  config.authenticate_with do
    # Use sorcery's before filter to auth users
    require_login
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan

  config.included_models = %w(
    Account Accountstatus Accountinvoice Accountinvoicestatus Accountinvoicetype Accountpaymentmethod
    Appversion Paymentplan Feature Paymentplanfeature Asset Booking
    Event Planningstatus Onlinestatus Eventtemplate Eventtype
    Paymentplan Placeholder Role User)

  config.model 'Accountinvoicestatus' do
    parent Accountinvoice
  end

  config.model 'Accountinvoicetype' do
    parent Accountinvoice
  end

  config.model 'Accountpaymentmethod' do
    parent Account
  end

  config.model 'Accountstatus' do
    parent Account
  end

  config.model 'Planningstatus' do
    parent Event
  end

  config.model 'Onlinestatus' do
    parent Event
  end

  config.model 'Paymentplan' do
    parent Appversion
  end

  config.model 'Feature' do
    parent Appversion
  end

  config.model 'Paymentplanfeature' do
    parent Appversion
  end

  config.model 'Eventtype' do
    visible false
  end

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete

    switch_user
    root :key_metrics do
      link_icon 'fa fa-line-chart'
      controller do
        proc do
          @key_metrics = Admin::KeyMetricsFacade.new
        end
      end
    end

    root :features do
      link_icon 'fa fa-toggle-on'
      controller do
        proc do
          @appversions = Appversion.all
          @paymentplans = Paymentplan.all
          @features = Feature.all
        end
      end
    end
  end
end

# Workaround for will_paginate
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end
