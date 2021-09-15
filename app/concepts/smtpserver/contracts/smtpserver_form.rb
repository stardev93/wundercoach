require 'reform/form/validation/unique_validator'
# default user form for both creating and updating
class SmtpserverForm < Reform::Form
  property :from_address
  property :from_name
  property :replyto_address
  property :server
  property :port
  property :username
  property :password
  property :ssl
  property :starttls
  property :authentication
  property :openssl
end
