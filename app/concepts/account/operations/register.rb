require "account/account_setup_paymenterms" 

class Account < ApplicationRecord
  # Creates an Account from the Registration Form
  class Register < Trailblazer::Operation
    # flag that decides if activation mails are sen
    self['user.use_activation'] = true

    step :model!
    step Contract::Build(constant: RegistrationForm)
    step Contract::Validate()
    step :build_default_eventtypes!
    success :populate_attributes!
    success :load_css!
    step Wrap ->(*, &block) { ActiveRecord::Base.transaction { block.call } } {
      step Contract::Persist()
      success :populate_paymentmethods!
      success :copy_mailskins!
      success :activate_paymentmethods!
      success :post_creation_setup!
      success :populate_smtpservers!
      success :populate_pdftemplates!
      success :setup_user!
      success :create_widgets!
      success :create_paymentterms!
      success ->(model:, **) { AdminMailer.delay.account_creation_notice(model) }
    }

    private

    def model!(options)
      options['model'] = Account.new(creator: User.new, affiliate: options['affiliate'])
    end

    def populate_attributes!(model:, **)
      model.assign_attributes({
        accountstatus: Accountstatus.find_by(key: 'active'),
        active: true,
        terms_required: false,
        gdpr_required: false,
        revocation_required: false,
        vat_included: true,
        vat_net_first: false,
        show_header_image: true,
        token: SecureRandom.uuid,
        invoice_no_start: 10_000,
        cancellation_no_start: 20_000,
        order_confirmation_no_start: 50_000,
        order_no_start: 40_000,
        quote_no_start: 30_000,
        account_receivable_no_start: 10000,
        account_receivable_autonumbering: true,
        show_get_started_modal: true,
        tracking_code_active: false,
        time_zone: "Europe/Berlin"
      })
    end

    def populate_paymentmethods!(model:, **)
      model.paymentmethods << Paymentmethod.where(key: %w[banktransfer vorkasse free])
    end

    def copy_mailskins!(model:, **)
      Mailskin.system.each do |skin|
        new_skin = skin.dup
        skin.mailtemplates.system.each do |template|
          new_template = template.dup
          new_template.assign_attributes account: model
                                         # reply_to: model.email
          new_skin.mailtemplates << new_template
        end
        model.mailskins << new_skin
      end
    end

    def build_default_eventtypes!(model:, **)
      model.eventtypes.build key: 'seminar', name: 'Seminar', description: 'Seminar mit mehreren Teilnehmern', locale: 'de'
      model.eventtypes.build key: 'coaching', name: 'Individuell', description: 'Veranstaltung mit individueller Terminvereinbarung', locale: 'de'
      #model.eventtypes.build key: 'seminar', name: 'Seminar', description: 'Seminar with multiple participants', locale: 'en'
    end

    def activate_paymentmethods!(model:, **)
      model.accountpaymentmethods.each(&:activate)
    end

    def load_css!(model:, **)
      model.css_code = File.read(
        Rails.root.join('app', 'assets', 'stylesheets', 'signup', 'default.css')
      )
    end

    # sets subdomain and creates a first TrialBooking.
    # Requires persisted Account, so we cannot call this as after_create callback
    def post_creation_setup!(model:, **)
      model.bookings.build paymentplan: Paymentplan.premium,
                           type: 'TrialBooking',
                           valid_until: 1.month.from_now,
                           is_current: true
      vats_from_germany = VatCountry.find_by(country: 'DE')
      model.vat_countries << vats_from_germany
      model.default_vat = Vat.find_by(vat_country: vats_from_germany, key: 'regular_vat')
      model.default_currency_iso_code = 'EUR'
      model.subdomain = model.accountnumber.to_s
      # copy user's email
      model.email = model.creator.email
      model.save
    end

    def create_widgets!(model:, **)
      Widget.create([{
        account: model,
        name: 'Anmeldeliste',
        description: 'Zeigt eine Liste aller kommenden Veranstaltungen an.',
        html: File.read(Rails.root.join('app', 'views', 'widgets', 'seminar_sample.liquid'))
      }, {
        account: model,
        description: 'Zeigt Infos zur nächsten Veranstaltung an.',
        name: 'Kommendes Seminar',
        html: File.read(Rails.root.join('app', 'views', 'widgets', 'event_show_sample.liquid'))
      }])
    end

    # create paymentterms that are displayed and editable per account for checkout and (later) for invoice etc.)
    def create_paymentterms!(model:, **)
      AccountSetupPaymenterms.new(model).perform
    end

    def setup_user!(options)
      model = options['model']
      model.users.each do |user|
        user.assign_attributes({
          external: false,
          gender: model.gender,
          firstname: model.firstname,
          lastname: model.lastname,
          time_zone: "Europe/Berlin"
        })
        user.setup_activation if options['user.use_activation']
        user.roles << Role.find_by(name: 'user')
        user.save!
        UserMailer.internal_activation_needed_email(user).deliver_later if options['user.use_activation']
        user.delay.register_at_mailchimp! if Rails.env.production?
      end
    end

    # fill the smtpservers with 2 values:
    # 1. wundercoach_standard server with a standard server for sending with valid settings, using a reply-to address from the account model.creator.email
    # 2. an empty record for entering own smtpserver settings.
    def populate_smtpservers!(model:, **)
      Smtpserver.create([
        {account: model, key: 'wundercoach_standard', server: "mail.businesshosting24.com", port: "465", username: "go@wundercoach.net", password: "61d2c1Uk4", ssl: true, active: true, from_address: "go@wundercoach.net", from_name: model.name, replyto_address: model.creator.email},
        {account: model, key: 'custom', server: "", port: "", username: "", password: "", ssl: true, active: false, from_address: model.creator.email, from_name: model.name, replyto_address: model.creator.email}
        ])
    end

    def populate_pdftemplates!(model:, **)
      Pdftemplate.create([
        {account: model, name: 'Teilnahmebestätigung', body_code: '<body>
        <div class="row">
          <div class="col-xs-12 text-center">
            <h1>Zertifikat</h1>
            <p>über die erfolgreiche Teilnahme am Seminar</p>
            <h1>{{event.name}}</h1>
            <p>Datum: {{event.start_date}}</p>
          </div>
         </div>
        <div class="row">
          <div class="col-xs-12 text-center">
            <h1>{{address.firstname}} {{address.lastname}}</h1>
          </div>
        </div>
        </body>', css: 'body {
           margin: 0px;
           padding: 0px;
           background-image: url(\'/Applications/MAMP/htdocs/wundercoach/app/views/pdftemplates/bg.png\'); background-repeat: no-repeat; width: 100px, height: 150px;
           display: block;
        }', top: '0px', bottom: '0px', left: '0px', right: '0px'}
        ])
    end

  end
end
