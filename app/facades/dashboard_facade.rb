# offers data for the dashboard-charts
class DashboardFacade
  def initialize(date = nil)
    @date = date || Date.today
  end

  def sales_by_location_chart
    sales_by_location
  end

  def sales_chart
    [{ data: sales, label: "#{I18n.t(:sales)} #{@date.year}" }]
  end

  def event_days_by_period_chart
    [{ data: event_days, label: "#{I18n.t(:events)} #{@date.year}" }]
  end

  private

  # Sales by location for dashboard chart
  def sales_by_location
    sales_values = []
    city_names = []
    Event.by_year(@date)
         .joins(eventbookings: {order: { businessdocuments: :businessdocumentpositions }})
         .select('SUM(businessdocumentpositions.price_cents * businessdocumentpositions.amount / 100) price_sum', 'events.city the_city')
         .group('events.city')
         .each do |city_sum|
           city_names << city_sum.the_city
           sales_values << city_sum.price_sum
         end
    { labels: city_names, data: sales_values }
  end

  # returns sales of one year as an array as needed by flot line charts,
  # i.e. [[1, 23], [2, 35], ...]
  def sales
    sales_data = Billing::Businessdocument.joins(:businessdocumentpositions)
                        .by_year(@date)
                        .group_by_month('businessdocuments.invoice_date')
                        .sum('businessdocumentpositions.price_cents * businessdocumentpositions.amount / 100')
    sales_data.default = 0
    (1..12).map {|month| [month, sales_data[Date.new(@date.year, month, 1)]] }
  end

  # Returns monthly event count for dashboard charts
  def event_days
    event_data = Event.by_year(@date).group_by_month(:start_date).count
    event_data.default = 0
    (1..12).map {|month| [month, event_data[Date.new(@date.year, month, 1)]] }
  end
end
