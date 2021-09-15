class AddressDecorator < Draper::Decorator

  delegate_all

  def context
    {
      'account_id' => object.account_id,
      'company' => object.company,
      'firstname' => object.firstname,
      'lastname' => object.lastname,
      'gender' => object.gender,
      'email' => object.email,
      'street' => object.street,
      'zip' => object.zip,
      'city' => object.city,
      'country' => object.country,
      'telephone' => object.telephone
    }
  end

  def full_address

      retval = (address.company.present? ? address.company + "\r\n" : "")
      retval += I18n.t(:"#{address.gender}_indirect")
      retval += " " + address.fullname
      retval += "\r\n"
      retval += address.street
      retval += "\r\n"
      retval += address.zip + ' ' + address.city
      retval += "\r\n"
      retval += address.country_name

      return retval
  end

  def participant
    I18n.t(:"#{gender}_indirect") + " #{lastname}, #{firstname}"
  end
  private

end
