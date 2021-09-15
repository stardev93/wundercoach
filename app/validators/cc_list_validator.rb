# validates a list of emails separated by semicolons. errors if at least one is invalid
class CcListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    mail_addresses = value.split(',').map {|address| address.chomp.strip }.select(&:present?)
    mail_addresses.each do |mail_address|
      unless mail_address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        record.errors[attribute] << (options[:message] || "#{mail_address} #{I18n.t(:is_not_an_email)}")
      end
    end
  end
end
