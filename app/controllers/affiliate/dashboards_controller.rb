class Affiliate < ActiveRecord::Base
  # Affiliate Dashboard
  class DashboardsController < BaseController
    before_filter { authorize!(:read, @affiliate) }

    def show
      @accounts = @affiliate.accounts.page(params[:page])
      # @adpartners = @affiliate.adpartners.page(params[:page])
      @event_lists = @affiliate.event_lists.includes(:tags).page(params[:page])
      @events = @affiliate.events.page(params[:page]).includes(:affiliate_tags)
      # @tags = @affiliate.tags.page(params[:page])
      @orders = @affiliate.orders.includes(:product, :adpartner, :account).page(params[:page])
    end

    private

    def set_affiliate
      @affiliate = current_user.account.affiliate
    end
  end
end
