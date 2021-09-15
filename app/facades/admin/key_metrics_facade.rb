class Admin::KeyMetricsFacade
  def initialize(from_date = nil, to_date = nil)
    @from_date = from_date || Date.today.at_beginning_of_month
    @to_date = to_date || Date.today

    @accounts = Account.unscoped
    @bookings = Booking.paid
  end

  # get the number of signups (new accounts created) between from_date and to_date
  def signups_count
    @accounts.where("created_at >= '#{@from_date}' and created_at <= '#{@to_date}'").count || 0
  end

  # get the number of signups per interval (new accounts created) between from_date and to_date
  def signups_count_by_interval
    accounts_by_period.having('month = ?', Date.today.at_beginning_of_month).count.values.first
  end

  def churn_count
    @accounts.where("deleted_at >= '#{@from_date}' and deleted_at <= '#{@to_date}'").count || 0
  end

  def total_accounts_count
    Account.all.count
  end

  def churn_count_by_interval
    @accounts.group_by_month(:deleted_at).having('month = ?', Date.today.at_beginning_of_month).count.values.first || 0
  end

  def churn_statistics
    @accounts.group_by_month(:deleted_at).count || 0
  end

  def signups_statistics(period)
    accounts_by_period(period).count
  end

  def estimated_revenue_sum
    @bookings
      .select("CASE paymentplans.cycle WHEN 'monthly' THEN paymentplans.price ELSE paymentplans.price / 12 END / 100 AS real_price")
      .reduce(0) {|sum, booking| sum + booking.real_price }
  end

  def estimated_revenue_statistics
    # TODO: Only works for monthly bookings
    BillingPeriod.group_by_month(:start_date, format: '%b %Y').sum('price / 100')
  end

  # FIXME: What does this statistic tell us? is it correct? Because the graph looks strange.
  def paymentplan_statistics
    plans = Paymentplan.all.map do |plan|
      {
        name: plan.name,
        data: BillingPeriod.unscoped.joins(:booking).where(bookings: { paymentplan_id: plan.id }).group_by_month(:start_date, format: '%b %Y').count
      }
    end
    plans.reject {|plan| plan[:data].empty? }
  end

  private

  def accounts_by_period(period = :month)
    # @accounts.group_by_month(:created_at).order("created_at")
    @accounts.group_by_period(period, :created_at).order('created_at')
  end
end
