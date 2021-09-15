# Wundercoach #

## Installation

```sh
$ # the repo ist still called seminarmanager
$ git clone git@bitbucket.org:wundercoach/wundercoach.git
$ cd wundercoach
$ # if you haven't already, install the required ruby version, e.g. using rbenv:
$ rbenv install 2.3.1
$ gem install bundler
$ # if you have MAMP installed, you can use it's mysql database. Configure bundler to use the MAMP mysql lib:
$ bundle config build.mysql2 --with-mysql-config=/Applications/MAMP/Library/bin/mysql_config
$ # now, install all the gems:
$ bundle
$ # almost done! Proceed with database preparation.
```

### Prepare the database for Wundercoach
Make sure you have an empty database called *wundercoach*.
Wundercoach requires timezone support to display charts. Install it by downloading and executing this [SQL code](https://gist.githubusercontent.com/ankane/1d6b0022173186accbf0/raw/time_zone_support.sql):

```sh
$ mysql -uroot -p mysql < time_zone_support.sql
```
or use the local copy

```sh
$ mysql -uroot -p mysql < misc/mysql_timezonesupport/timezone.sql
```

You installed Wundercoach! Now proceed with the Setup.

## Setup

**Populating the database with Test data:** (this will reset the current database before populating, don't use in production!)
```sh
$ rake wc:dd
```
**Seeding the database:**
```sh
$ rake db:seed # fill an empty database
$ rake db:setup # create and fill database
$ rake db:reset # drops current database (!) and calls setup
```
**Using Subdomains on your local machine**

Instead of 0.0.0.0:3000, use **go.lvh.me:3000**. That's basically the same, but it works with subdomains. *Using the Wundercoach without subdomains is no longer possible!*


## Signup/Checkout ##

1. Enter your data
2. Choose a payment method
3. Confirm and get an invoice OR pay at one of our payment providers
4. Congratulations, you booked an event!

[sofort.com API Manual](https://www.sofort.com/integrationCenter-ger-DE/content/view/full/2513)

## Features

Depending on the chosen payment plan, clients may or may not access some advanced features.
Accessability of features is defined using cancan in *ability.rb*

[How to work with features](https://bitbucket.org/siliconplanet/seminarmanager/wiki/Features)

## Deploy ##

There are 2 stages to deploy to, **staging** and **production**.

[How to Deploy the Wundercoach](https://bitbucket.org/siliconplanet/seminarmanager/wiki/Deploy)

## Payment

Payment is possible via [Stripe](https://bitbucket.org/siliconplanet/seminarmanager/wiki/Stripe) and Gocardless

### Payment Adapters

Each Account generates a PaymentAdapter when you choose a paid plan for the first time. PaymentAdapters store the data necessary to process payment (e.g. the stripe customer_id) and contain all payment logic. The account doesn't even have to know if payment is done via stripe or invoice. It's important to keep these details in mind:

- accounts are generated without adapter, and can only have one adapter at a time
- some actions, like paymentplans#chooseplan, require an adapter
- switching between Invoice and Stripe is currently not supported.

## Mailers

ApplicationMailer is the top-level Mailer class
we send emails for different purposes

**Wundercoach system emails**

0. WcoachMailer: Wundercoach Mailer MasterClass for system mails, implements smtp settings
1. Wundercoach registrations: AdminMailer > account_creation_notice
2. Wundercoach Customer Billing: AccountinvoiceMailer > send_invoice
3. Wundercoach Customer Expiry Reminders: BookingMailer > send_expiry_reminder_one and other
4. UserMailer: User Activation and Password reset.

**Developer emails**

5. Developer emails: Messages for developers

**Customer emails**

6. CustomerMailer: MasterClass for all Customers Mail Actions, inherits from ApplicationMailer, implements send_composed_mail method,
   renders tenants Mailtemplates
7. EventMailer: inherits from CustomerMailer and is used with parent class methods
8. InvoiceMailer: send account invoice to accounts customers for participation
9. SmtpserverMailer: send Test Emails when setting up customers own smtp settings

**Mailer inheritance scheme:**

ApplicationMailer

  => CustomerMailer

    => EventMailer
    => InvoiceMailer

  => WcoachMailer

    => AccountinvoiceMailer

    => AdminMailer

    => BookingMailer

    => DeveloperMailer

    => UserMailer

  => SmtpserverMailer


## Misc

### Making a backup of the live database / syncing your database
```sh
$ be cap production db:pull
```
The dump will be stored on the top level of your local application directory. You will be asked if you want to overwrite your database. If you chose *no*, the dump will still be downloaded.

### Syncing with the live system
```sh
$ be rake db:drop db:create
$ be cap production app:pull
```
This will sync both your database and all assets with the live system. We use the [capistrano-db-tasks](https://github.com/sgruhier/capistrano-db-tasks) gem for syncing.

## Testing
Before testing, you need to seed your test-database.

```sh
$ rake db:setup RAILS_ENV=test
```

If you already have a test-database and want to repopulate it, use

```sh
$ rake db:reset RAILS_ENV=test
```

We use *factory-girl* for fixtures and *rspec* for testing. To run all available
tests, run:
```sh
$ rspec
```
All tests and factories can be found in the spec folder.

## Troubleshooting

Error message during signup:

The change you wanted was rejected (live & staging) or InvalidAuthenticityToken Exception (dev).

You may get these errors if you are logged in at the backend and testing signup at the same time, in the same browser.
If you are logged in at the backend, **try opening signup in a private tab**.
You will also get this error if you have cookies deactivated.

## Google Maps Integration
We are using google maps (Maps JavaScript API) in app/views/events/_googlemap_scripts.html.slim
Add the following API Key "Wundercoach Production API key" from https://console.cloud.google.com
Project-Name is wundercoach, Login with go@wundercoach.net
Der Schlüssel lautet AIzaSyAxjS_O7x8mXyVV6_ftf8qe6YTIGmy0huA und ist auf die Domains *.wundercoach.net beschränkt
