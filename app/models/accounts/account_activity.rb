class AccountActivity < Account
  # calculate the setup grade of account depending on
  # how deep the customer digs into the usage of wundercoach
  # assumed onboarding stages:
  # 1. looking around: what can wundercoach do for me?
  # 2. testing a little: testing more detailed functions like signup process, logo upload
  # 3. serious efforts: setting up payment methods, invoicing setup, mail texts
  # 4. frequent usage: customer is using the system

  # basic setup completed (3 or more events created)
  # advanced setup completed (payment mehtods setup, paid plan booked)
  # testing deeper?: more detailed functions like billing, integration in website, design changes
  def self.model_name
    Booking.model_name
  end

  def activity_index
    setup_grade = 100
    setup_grade
  end
end
