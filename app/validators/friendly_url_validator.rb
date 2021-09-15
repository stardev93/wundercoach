class FriendlyUrlValidator < ActiveModel::Validator
  def validate(record)
    if !record.slug.match(/\A[a-z0-9\d-]+\z/i)
      record.errors[:slug] << I18n.t(:slug_invalid)
    end
  end
end
