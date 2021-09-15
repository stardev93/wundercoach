# Provides a robots.txt depending on environment
# disallows everything when not in production
class RobotsTxt
  def self.call(_env)
    # start building a new response
    response = Rack::Response.new

    # set content type to plain txt file
    response['Content-Type'] = 'text/plain'
    # cache the response for one year, so that further requests won't hit
    # the application
    response['Cache-Control'] = 'public, max-age=31557600' # cache for 1 year

    # if we're not in production env, set the content to disallow all robots
    robots_text =
      if Rails.env.production?
        <<~ROBOTS
          User-agent: *
          Disallow: /
          Allow: /*/signup
        ROBOTS
      else
        # disallow access to the whole site (/) for all agents (*)
        <<~ROBOTS
          User-agent: *
          Disallow: /
        ROBOTS
      end

    response.write robots_text

    response.finish
  end
end
