class Address < ActiveRecord::Base
  acts_as_tenant(:account)
  include HasCountry

  nilify_blanks

  FORM_ATTRIBUTES = %i(country company lastname firstname gender telephone email zip city street id).freeze

  validates :lastname, :firstname, :gender, :email, :street, :zip, :city, :country, presence: true
  validates :email, email: true

  def to_s
    unless company.blank?
      "#{company}"
    else
      "#{firstname} #{lastname}"
    end

  end

  def fullname
    "#{firstname} #{lastname}"
  end

  # FIXME: Use rails view helpers or a decorator for formatting attributes
  def gender_indirect
    case gender
    when 'm'
    when 'male'
      I18n.t('gender_indirect_m')

    when 'f'
    when 'female'
      I18n.t('gender_indirect_f')

    when 'd'
    when 'diverse'
      I18n.t('gender_indirect_diverse')

    when 'n'
    when 'noinfo'
      I18n.t('gender_indirect_noinfo')
    else
      ""
    end

  end

  def gender_direct
    case gender
    when 'm'
    when 'male'
      I18n.t('gender_direct_m')
    when 'f'
    when 'female'
      I18n.t('gender_direct_f')
    when 'd'
    when 'diverse'
      I18n.t('gender_direct_diverse')
    when 'n'
    when 'noinfo'
      I18n.t('gender_direct_noinfo')
    else
      ""
    end

  end

  def salutation

    case gender
    when 'm'
    when 'male'
      I18n.t('gender_direct_m')
    when 'f'
    when 'female'
      I18n.t('gender_direct_f')
    when 'd'
    when 'diverse'
      I18n.t('gender_direct_diverse')
    when 'n'
    when 'noinfo'
      I18n.t('gender_direct_noinfo')
    else
      ""
    end
  end
end
