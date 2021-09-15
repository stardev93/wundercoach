Rails.application.routes.draw do

  if Rails.env.development?

  end
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/v2"
  post "/v2", to: "graphql#execute"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if (Rails.env.development? or Rails.env.staging?)

  resources :items
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  # dynamic robots.txt, disallows everything if not in production mode
  require "#{Rails.root.join('lib', 'robots_txt.rb')}"
  get '/robots.txt' => RobotsTxt

  # default locale
  get "/", to: redirect("/#{I18n.locale}/")

  # this engine takes care of stripe webhooks
  mount StripeEvent::Engine, at: "/stripe"

  # gocardless webhooks and oauth
  namespace :gocardless do
    post "/" => "webhooks#create"
    get "/oauth/callback" => "oauth#callback"
    get "/oauth/redirect" => "oauth#redirect"
  end

  # stripe oauth
  namespace :stripe do
    get "/oauth/callback" => "oauth#callback"
    get "/oauth/redirect" => "oauth#redirect"
  end

  namespace :api do
    namespace :v1 do
      scope :jsonp do
        get "/full_filterable_list/:widget_token.js" => "jsonp#full_filterable_list", defaults: { format: 'js' }, as: :full_filterable_list
        get "/bundle_event_list/:widget_token.js" => "jsonp#bundle_event_list", defaults: { format: 'js' }, as: :bundle_event_list
        get "/individual_event_list/:widget_token.js" => "jsonp#individual_event_list", defaults: { format: 'js' }, as: :individual_event_list
        get "/filtered_list/:widget_token.js" => "jsonp#filtered_list", defaults: { format: 'js' }, as: :filtered_list
      end
    end
  end

  get "/eventtemplate/:eventtemplate_slug/:widget_token" => "eventtemplate/widgets#show", defaults: { format: 'js' }, as: :eventtemplate_widget_script
  get "/event_list/:event_list_id/:widget_token" => "affiliate/event_list/widgets#show", defaults: { format: 'js' }, as: :event_list_widget_script
  get "/adpartner/:adpartner_id/:event_list_id/:widget_token" => "adpartner/widgets#show", defaults: { format: 'js' }, as: :adpartner_widget_script

  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do
    get "app/dashboard/dashboard" => "dashboard#dashboard"

    namespace :crm do
      resources :contacts
      resources :persons, :controller => 'crm_contacts'
      resources :companies, :controller => 'crm_contacts'
      get "contact_addresses/:id/primary" => "contact_addresses#primary", as: "contact_addresses_primary"
      resources :contact_addresses
      resources :contact_details
      resources :contact_tags
      resources :contact_details
    end

    resources :smtpservers
    get "smtpservers/:id/activate" => "smtpservers#activate", as: "activate_smtpserver"
    get "smtpservers/:id/testconnection" => "smtpservers#testconnection", as: "testconnection"

    namespace :affiliate do
      resources :accounts do
        post 'login_as', on: :member
      end
      resources :events, except: %i(new create destroy)
      resources :event_lists
      resources :tags
      resource :dashboard
      resources :adpartners do
        resources :websites, shallow: true
      end
    end

    namespace :admin do
      resources :affiliates

      resources :bookings do
        member do
          get 'makecurrent'
        end
      end

      resources :billing_periods

      resources :accounts do
        collection do
          get 'compute'
          get "deactivate/:id" => "admin#accounts#activate", as: :deactivate
        end
        member do
          get 'login_as'
        end
      end

      resources :accountinvoices

      resources :accountinvoicestatuses

      resources :accountinvoicetypes

      resources :accountinvoicepositions

      resources :appversions

      resources :bookings
      get "accountinvoices/:id/createnew" => "accountinvoices#createnew", as: "accountinvoices_createnew"
      get "accountinvoices/:id/cancel" => "accountinvoices#cancel", as: "accountinvoices_cancel"
      get "accountinvoices/:id/sendaccountinvoice" => "accountinvoices#sendaccountinvoice", as: "sendaccountinvoice"
      get "accountinvoices/:id/pdf" => "accountinvoices#pdf", as: "accountinvoices_pdf"
      get "accountinvoices/:id/download" => "accountinvoices#download", as: "accountinvoices_download"

      get 'dashboard/index' => "dashboard#index", as: "dashboard"
      get 'backend/:id/accountdetails' => "backend#accountdetails", as: "backend_accountdetails"
      get 'backend/bookings' => "backend#bookings", as: "backend_bookings"
      get 'backend/invoices' => "backend#invoices", as: "backend_invoices"

      resources :features
      get "features/:id/populate" => "features#populate", as: "features_populate"
      get "features/:id/sort_down" => "features#sort_down", as: "features_sort_down"
      get "features/:id/sort_up" => "features#sort_up", as: "features_sort_up"
      post "features/:id/position" => "features#position"

      get 'messages/:id/publish' => "messages#publish", as: "message_publish"
      get 'messages/:id/unpublish' => "messages#unpublish", as: "message_unpublish"

      get 'messages/:id/push' => "messages#push", as: "message_push"
      get 'messages/:id/mute' => "messages#mute", as: "message_mute"

      resources :messages

      resources :payment_adapters
      resources :paymentplans
      resources :paymentplanfeatures
      get "paymentplanfeatures/:id/setappversion" => "paymentplanfeatures#setappversion", as: "paymentplanfeatures_setappversion"
      get "paymentplanfeatures/:id/setvalue" => "paymentplanfeatures#setvalue", as: "paymentplanfeatures_setvalue"

      resources :placeholders
    end

    get "accountinvoices/:id/pdf" => "accountinvoices#pdf", as: "accountinvoices_pdf"

    # resources :bundles do
    #   resources :orders, only: %i(new create), controller: "bundle/orders"
    #   # add/remove events to bundle
    #   resources :event, only: %i(update destroy), controller: "bundles_events"
    #   # post "event/:event_id" => "bundles_events#create"
    #   # delete "event/:event_id" => "bundles_events#destroy"
    # end

    # =Signup

    # all signup controllers go here
    namespace :signup do
      # ==Checkout
      # Events
      post '/events/:slug', to: 'events#create_order', as: 'event'
      #match '/events/:slug', to: 'events#create_order', as: 'event', via: [:get, :post]
      get '/events/:slug', to: 'events#show', as: 'show_event'
      get '/:slug/show', to: 'events#show', as: 'show_event_old'

      # Bundles
      # post '/bundles/:slug', to: 'bundles#create_order', as: 'bundle'
      # get '/bundles/:slug', to: 'bundles#show', as: 'show_bundle'

      resources :orders, only: %i(update edit show), path_names: { edit: 'contact' } do
        member do
          get 'payment'
          post 'set_payment'
          get 'confirm'
          post 'final_confirm'
        end
      end
      # ==Payment
      scope :sepa do
        # something like this...
        post "/:id", to: 'gocardless#redirect', as: 'gocardless_redirect'
        get "/:id", to: 'gocardless#success', as: 'gocardless_success'
      end
      scope :sofort do
        post "/:id", to: 'sofort#create', as: 'sofort'
        get "/:id/thankyou/:sofort_id", to: 'sofort#success', as: 'sofort_success'
      end
      scope :stripe do
        post "/:id", to: 'stripe#create', as: 'stripe'
      end
      scope :paypal do
        post "/:id", to: 'paypal#create', as: 'paypal'
      end
    end

    # namespace :event do
    #   resources :tags
    # end

    namespace :account do
      resource :preferences, only: %i(update)
      resource :active_campaign
      namespace :paymentmethods do
        get "sofort", to: "sofort#edit"
        patch "sofort", to: "sofort#update"
        get "paypal", to: "paypal#edit"
        patch "paypal", to: "paypal#update"
      end
    end

    resources :widgets

    scope "/register" do
      get "new" => "register#new", as: "register_new"
      post "create" => "register#create", as: "register_create"
      get 'success' => "register#success", as: "register_success"
      get "terms" => "register#terms", as: "register_terms"
      get "privacy" => "register#privacy", as: "register_privacy"

      # register for affiliate routes
      post "create/:affiliate_token" => "register#create", as: "register_create_for_affiliate"
    end

    get "marketing" => "marketing#index"

    resource :mailchimp do
      post "sync"
    end

    # CRM
    resources :filters

    resources :campaigns do
      resources :target_groups, only: %i(index new create) do
        resources :filters, shallow: true
      end
      member do
        post "remove_target_group"
        post "add_target_group"
        post "sync"
      end
    end

    resources :target_groups do
      resources :filters, shallow: true
      member do
        post "remove_filter"
        post "add_filter"
      end
    end

    resources :eventtemplates do
      member do
        get "duplicate"
        patch "updateevents"
      end
    end

    # For generating events from requests
    resources :requests do
      resources :events, only: :create
    end

    get "eventtemplates/:id/createevent" => "eventtemplates#createevent", as: "eventtemplate_createevent"
    get "eventtemplates/:id/editseo" => "eventtemplates#editseo", as: "eventtemplate_editseo"
    patch "eventtemplates/:id/saveseo" => "eventtemplates#saveseo", as: "eventtemplate_saveseo"

    scope "/seminare" do
      get "index" => "landingpages#index", as: "landingpage_index"
      get ":id/show" => "landingpages#show", as: "landingpage_show"
    end

    resources :coaches
    get "coach/:id/removeimage" => "coaches#removeimage", as: "coach_removeimage"

    resources :mailskinassets
    get "mailskinassets/:id/remove" => "mailskinassets#remove", as: "mailskinasset_remove"
    get "mailskinassets/:mailskin_id/load" => "mailskinassets#load", as: "mailskinasset_load"

    resources :mailskins
    get "mailskins/:id/preview" => "mailskins#preview", as: "mailskin_preview"

    resources :vats
    resources :vat_revenue_accounts

    namespace :billing do
      resources :invoicestatuses
      resources :invoicetypes
      resources :businessdocumentpositions
      get 'businessdocuments/datevexport' => "businessdocuments#datevexport", as: "datevexport"
      post 'businessdocuments/datevdownload' => "businessdocuments#datevdownload", as: "datevdownload"
      get "businessdocuments/:id/createcontact" => "businessdocuments#createcontact", as: "businessdocuments_createcontact"
      get "businessdocuments/:id/assigncontact/:contact_id" => "businessdocuments#assigncontact", as: "businessdocuments_assigncontact"

      resources :businessdocuments do
        member do
          get 'businessdocuments/:id/new_quote' => "businessdocuments#new_quote", as: "new_quote"
          get 'businessdocuments/:id/new_order' => "businessdocuments#new_order", as: "new_order"
          get 'businessdocuments/:id/new_cancellation' => "businessdocuments#new_cancellation", as: "new_cancellation"
          get 'businessdocuments/:id/duplicate' => "businessdocuments#duplicate", as: "duplicate"
          get 'businessdocuments/:id/duplicateposition' => "businessdocuments#duplicateposition", as: "duplicateposition"
          delete 'businessdocuments/:id/deleteposition' => "businessdocuments#deleteposition", as: "deleteposition"
          post "send_to_customer"
        end
      end
      get 'businessdocuments/:contact_address_id/new_invoice' => "businessdocuments#new_invoice", as: "new_invoice"
      get 'businessdocuments/:contact_address_id/new_quote' => "businessdocuments#new_quote", as: "new_quote"
      get "businessdocuments/:id/create_pdf" => "businessdocuments#create_pdf", as: "businessdocument_create_pdf"
      get "businessdocuments/:id/download" => "businessdocuments#download", as: "businessdocument_download"
      get "businessdocuments/:id/cancel" => "businessdocuments#cancel", as: "businessdocument_cancel"
      post 'businessdocuments/:id/paid/:paid' => 'businessdocuments#set_paid', as: 'set_paid_businessdocument'
    end

    resources :planningstatuses

    resources :onlinestatuses
    resources :accountpaymentmethods
    get "accountpaymentmethods/:id/activate" => "accountpaymentmethods#activate", as: "activate_accountpaymentmethod"
    get "accountpaymentmethods/:id/deactivate" => "accountpaymentmethods#deactivate", as: "deactivate_accountpaymentmethod"

    resources :eventpaymentmethods

    root 'dashboard#index'

    resources :userroles

    scope "/signup" do
      get '/' => "signup#index", as: "signup_index"
      get 'error' => "signup#error", as: "signup_error"
      get ':slug/redirect' => 'signup#redirect', as: 'signup_redirect'
      get ':slug/requests/new' => 'signup#new_request', as: 'signup_new_request'
      get 'not_found' => "signup#not_found", as: "signup_account_not_found"
    end

    resources :assets
    post "assets/destroyall" => "assets#destroyall", as: "assets_destroyall"

    resources :eventbookingstatuses

    get "classrooms/:token/index" => "classrooms#index", as: "classrooms"
    get "classrooms/:token/whiteboard" => "classrooms#whiteboard", as: "whiteboard"

    get "eventbookings/:id/createinvoice" => "eventbookings#createinvoice", as: "eventbookings_createinvoice"
    get "eventbookings/:id/createcontact" => "eventbookings#createcontact", as: "eventbookings_createcontact"
    post "eventbookings/:id/send_test/:template_id" => "eventbookings#send_test", as: "eventbookings_send_test"
    get "eventbookings/:id/certificate/:pdftemplate_id" => "eventbookings#certificate", as: "eventbooking_certificate"
    get "eventbookings/:id/move" => "eventbookings#move", as: "eventbookings_move"
    post "eventbookings/:id/movetoevent" => "eventbookings#movetoevent", as: "eventbookings_movetoevent"

    resources :eventbookings, except: %i(new) do
      member do
        get 'cancel'
      end
    end

    resources :mailtemplates
    get "mailtemplates/mailto" => "mailtemplates#mailto", as: "mailtemplates_mailto"
    get "mailtemplates/:eventbooking_id/mailto" => "mailtemplates#mailto", as: "mailtemplates_mailto_eventbooking"
    get "mailtemplates/:eventbooking_id/mailto/:mailtemplate_id" => "mailtemplates#mailto", as: "mailtemplate_mailto_eventbooking"
    get "mailtemplates/:eventbooking_id/sendmail/:mailtemplate_id/:address_id" => "mailtemplates#sendmail", as: "mailtemplate_sendmail"

    resources :paymentmethods
    resources :paymentstatuses
    resources :paymentterms

    match 'logout', to: 'sessions#destroy', via: [:get, :delete]
    get "login" => "sessions#new", as: "login"
    get "users/:id/activate" => "users#activate", as: "activate"
    get "users/:id/activateinternal" => "users#activateinternal", as: "activate_internal"

    # Coachings
    # new from request
    get 'requests/:id/new_appointment' => "individual_agreed_events#new", as: "event_from_request"
    # new from event
    get "/events/:slug/new_appointment" => "individual_agreed_events#new_from_event", as: "event_from_event"
    # create
    post 'requests/:request_id/appointment' => 'individual_agreed_events#create', as: 'individual_agreed_events'
    post 'events/:slug/appointment' => 'individual_agreed_events#create_from_event', as: 'individual_agreed_events_from_event'

    get "events/:id/onlinestatus" => "events#onlinestatus", as: "event_onlinestatus"
    get "events/:id/planningstatus" => "events#planningstatus", as: "event_planningstatus"
    get "events/:id/assigncoach/:coach_ids/" => "events#assigncoach", as: "event_assigncoach"
    get "events/:id/removecoach/:coach_ids" => "events#removecoach", as: "event_removecoach"
    get 'events/calendar' => 'events#calendar', as: :event_calendar

    post "events/:id/send_to_all/:template_id" => 'events#send_to_all', as: "event_send_to_all"

    resources :orders, only: %i(edit update destroy)

    resources :events do
      resources :orders, only: %i(new create), controller: "event/orders"

      member do
        put "regenerate_map"
        put "cancel"
        get "duplicate"
        get "pdf" => "events#pdf", as: "participantlist"
        get "assignsubevent/:subevent_id" => "events#assignsubevent", as: "assignsubevent"
        get "unassignsubevent/:subevent_id" => "events#unassignsubevent", as: "unassignsubevent"
      end
      collection do
        # create individual/free events
        get 'new_individual'
        get 'new_free'
        get 'new_online'
        get 'new_bundle'
      end
    end
    resources :items

    resources :eventtypes

    resources :accountstatuses

    resources :roles

    get 'users/:id/assignrole/:role_id' => 'users#assignrole', as: :users_assignrole
    get 'users/:id/revokerole/:role_id' => 'users#revokerole', as: :users_revokerole
    get 'users/:id/mutemessage/:message_id' => 'users#mutemessage', as: :user_mutemessage
    get 'users/messages' => 'users#messages', as: :users_messages
    get 'users/showmessage/:id' => 'users#showmessage', as: :users_showmessage

    resources :users do
      member do
        put "updatepassword"
        get "resetpassword"
      end
    end

    get "participants" => "users#participants", as: "participants"
    get "participants/:id" => "users#participant", as: "participant"
    get "users/:id/changepassword" => "users#changepassword", as: "user_changepassword"

    resources :sessions, only: %i(new create destroy)

    resources :password_resets, only: %i(new create edit update)

    resources :paymentplans do
      member do
        get "payment"
      end
    end

    get "showplans" => "paymentplans#showplans", as: "showplans"
    post "paymentplans/:id/chooseplan" => "paymentplans#chooseplan", as: "chooseplan"
    get "accountdata" => "paymentplans#accountdata", as: "accountdata"
    get "termsofservice" => "paymentplans#termsofservice", as: "termsofservice"
    get "ordersuccess" => "paymentplans#ordersuccess", as: "ordersuccess"
    get "enterprise" => "paymentplans#enterprise", as: "enterprise"

    get 'welcome' => 'accounts#welcome', as: :welcome
    get 'confirm' => 'users#confirm', as: :confirm
    get 'settings' => 'accounts#show', as: :settings # alias for show
    get 'editsettings' => 'accounts#editsettings', as: :edit_settings
    get 'generatetoken' => 'accounts#generatetoken', as: :generate_token

    get 'design' => 'accounts#design', as: :design
    get 'designedit' => 'accounts#designedit', as: :design_edit

    get 'domainsettings' => 'accounts#domainsettings', as: :domainsettings
    get 'domainsettingsedit' => 'accounts#domainsettingsedit', as: :domainsettingsedit
    patch 'domainsettingsupdate' => 'accounts#domainsettingsupdate', as: :domainsettingsupdate

    get 'eventdesignremove' => 'accounts#eventdesignremove', as: :eventdesignremove
    get 'toggleheaderimage' => 'accounts#toggleheaderimage', as: :toggleheaderimage

    get 'accountlogoremove' => 'accounts#accountlogoremove', as: :accountlogoremove

    get 'invoicedesign' => 'accounts#invoicedesign', as: :invoicedesign
    get 'invoicedesignedit' => 'accounts#invoicedesignedit', as: :invoicedesignedit
    get 'invoicelogoremove' => 'accounts#invoicelogoremove', as: :invoicelogoremove
    get 'invoicefooterremove' => 'accounts#invoicefooterremove', as: :invoicefooterremove

    get 'history' => 'accounts#history', as: :history
    get 'billing' => 'accounts#billing', as: :billing
    get 'payment' => 'accounts#payment', as: :payment

    get 'seosettings' => 'accounts#seosettings', as: :seosettings
    get 'seosettingsedit' => 'accounts#seosettingsedit', as: :seosettingsedit

    get 'smtpserversettings' => 'accounts#smtpserversettings', as: :smtpserversettings
    get "smtpserversettingsedit/:id" => "accounts#smtpserversettingsedit", as: :smtpserversettingsedit
    patch "smtpserversettingsupdate" => "accounts#smtpserversettingsupdate", :as => :smtpserversettingsupdate

    get 'iframe' => 'accounts#iframe', as: :iframe
    get 'togglewebsiteintegration' => 'accounts#togglewebsiteintegration', as: :toggle_websiteintegration

    patch "accounts/updateshort" => "accounts#updateshort", as: "updateshort"

    # Creation a payment_adapters, with or without creating bookings!
    post "stripe_checkout/:plan_id" => "stripe_payment_adapters#checkout", as: :stripe_checkout
    delete "payment_adapters/:id/destroy" => "payment_adapters#destroy", as: :destroy_payment_adapter

    scope "/payment" do
      post "/sepa" => "payment_adapters#gocardless_redirect", as: :redirect_to_gocardless
      get "/sepa" => "payment_adapters#gocardless_success", as: :gocardless_success
      post "/sepa/:plan_id" => "payment_adapters#gocardless_checkout_redirect", as: :gocardless_checkout_initiation
      get "/sepa/:plan_id" => "payment_adapters#gocardless_checkout", as: :gocardless_checkout_success
      get "/error" => "payment_adapters#error", as: :payment_error
    end

    namespace :product do
      resources :locations
      get '/locations/:id/removeicon' => 'locations#removeicon', as: :location_removeicon
      get '/locations/:id/generatemaps' => 'locations#generatemaps', as: :location_generatemaps
      get '/locations/:id/downloaddirectionspdf' => 'locations#downloaddirectionspdf', as: :location_downloaddirectionspdf
      get '/locations/:id/removedirectionspdf' => 'locations#removedirectionspdf', as: :location_removedirectionspdf

      resources :pricingsets
      get '/pricingsets/:id/assign/:event_id' => 'pricingsets#assign', as: :pricingsets_assign

      resources :pricingoptions do
        collection do
          post :sort
        end
      end

      resources :tags
    end


    resource :payment_adapter, only: %i(update create )
    resources :pdftemplates
    get 'pdftemplates/:id/removebgfile' => 'pdftemplates#removebgfile', as: :pdftemplate_removebgfile

    resource :account, except: %i(new create) do
      member do
        get 'payment' => 'payment_adapters#index'
        resource :stripe_payment_adapter, only: %i(create)
        get 'confirm_delete'
        #get "payment_adapters/:id/edit" => "payment_adapters#edit", as: :edit_payment_adapters
        #delete "payment_adapters/:id/destroy" => "payment_adapters#destroy", as: :destroy_payment_adapter
      end
    end
    resource :event_design, only: %i(show edit update), controller: 'account/event_design'
  end
  get "/:eventtemplate_slug/:widget_token.js" => "eventtemplate/widgets#show", as: :widget_script # legacy route
end
