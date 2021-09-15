# Defines Authorization rules
# https://github.com/CanCanCommunity/cancancan/
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    everybodys_abilities

    # Admin can do everything
    if user.has_role? 'admin'
      can :manage, :all
      can :manage, :backend
    elsif user.account.present?
      @myself = { id: user.id }
      @my_account = { id: user.account.id }
      @belongs_to_account = { account: @my_account }
      user_abilities if user.has_role? 'user'
      affiliate_abilities(user) if user.has_role? 'affiliate'

      # Signup / Checkout
      client_abilities # if user.has_role? "client"
    end

    cannot :signup, Event, &:booked_up?

    # # Make sure Invoices don't change after they have been sent to a customer
    # frozen = { invoicestatus: { key: %w(sent printed printed_and_sent) } }
    # cannot [:edit, :update, :destroy], Invoice, frozen
    # cannot [:edit, :update, :destroy], Invoiceposition, invoice: frozen
  end

  private

  def everybodys_abilities
    # Everyone can use activation links and create requests
    can :activate, User
    can :create, Request
    feature_check
    can :signup, [Event, Bundle], &:free_seats?
    can :create, Order, ->(order) { order.product.bookable? }
  end

  # Regular Backend-User of the wundercoach
  def user_abilities
    can :manage, User, @myself
    can :manage, User, @belongs_to_account
    can %i(read update welcome destroy), Account, @my_account
    can :manage, %i(marketing)
    can %i(pdf sendaccountinvoice), [
      Accountinvoice
    ], @belongs_to_account
    can :manage, [
      Asset, Bundle, Coach, Event, Eventtemplate, Eventbooking, Eventtype, Billing::Businessdocument, Billing::Businessdocumentposition,
      Request, Accountpaymentmethod, Item, Mailtemplate, Mailskin, Mailskinasset,
      Filter, TargetGroup, Campaign, Mailchimp, PaymentAdapter, StripePaymentAdapter,
      Widget, Vat
    ], @belongs_to_account
    can :create, Event
    can %i(showplans chooseplan payment accountdata termsofservice ordersuccess enterprise), Paymentplan
  end

  def feature_check
    # this decides whether boolean type Features are accessable.
    # other types are not yet in use, we'll build logic for them when we need it
    if ActsAsTenant.current_tenant.present?
      can :access, Feature, {
        fieldtype: 'boolean',
        paymentplanfeatures: {
          fieldvalue: '1',
          paymentplan: ActsAsTenant.current_tenant.paymentplan
        }
      }
    end
  end

  def affiliate_abilities(user)
    can :read, Affiliate, id: user.account.affiliate.id
  end

  # for event-signup process
  def client_abilities
    # thankyou action
    can :show, Order, user: @myself, status: Order.states_by_keys(%w(confirmed waiting_for_payment paid))
    # you can update any Order that belongs to you, unless you already confirmed it
    can %i(edit update), Order, user: @myself, status: Order.states_by_keys(%w(just_started data_completed payment_chosen))
    # you can set payment once you entered your contact info
    can %i(payment set_payment), Order, user: @myself, status: Order.states_by_keys(%w(data_completed payment_chosen))
    # Allow Confirmation if data is completed
    can %i(confirm), Order, user: @myself, status: Order.statuses[:payment_chosen]
    # Products without online payment
    can %i(final_confirm), Order, user: @myself, status: Order.statuses[:payment_chosen], paymentmethod: { key: %w(banktransfer vorkasse free) }
    sofort_actions
    stripe_actions
  end

  def stripe_actions
    # Sofort Payment
    can :pay_with_stripe, Order, user: @myself, status: Order.statuses[:payment_chosen], paymentmethod: { key: 'cc' }
  end

  def sofort_actions
    # Sofort Payment
    can :pay_with_sofort, Order, user: @myself, status: Order.statuses[:payment_chosen], paymentmethod: { key: 'sofort' }
    # Sofort Payment thankyou page
    can :view_sofort_thankyou_page, Order, user: @myself, status: Order.states_by_keys(%w(payment_chosen confirmed waiting_for_payment paid)), paymentmethod: { key: 'sofort' }
  end
end
