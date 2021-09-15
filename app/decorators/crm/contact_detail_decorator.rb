class Crm::ContactDetailDecorator < Draper::Decorator
  delegate_all

  CONTACT_DETAIL_TYPES_HASH = {
                                "" => "",
                                I18n.t(:email) => "email",
                                I18n.t(:private_phone) => "private_phone",
                                I18n.t(:work_phone) => "work_phone",
                                I18n.t(:mobile_phone) => "mobile_phone",
                                I18n.t(:website) => "website",
                                I18n.t(:other_detail) => "other_detail"
                              }.freeze
end
