class Paymentplanfeature < ActiveRecord::Base
  belongs_to :paymentplan
  belongs_to :feature

  # default_scope -> { includes(:feature).order('features.position ASC').references(:features) }

  # check if a connection between paymantplan and feature exists
  def self.exists_for(paymentplan, feature)
    # reduce queries, use enumrable instead of query all paymantplan-feature each time
    paymentplan.features.find(feature.id).paymentplanfeatures
    # if (paymentplanfeature = all_paymentplanfeatures.detect { |b| b["paymentplan_id"] == paymentplan_id && b["feature_id"] == feature_id })
    #   return paymentplanfeature
    # else
    #   return false
    # end
  end
end
