# this constant is used when there is no custom subdomain set.
# we cannot use wundercoach.net or www.wundercoach.net, since these domains
# belong to our wordpress site
EXTERNAL_SUBDOMAIN = case ENV["RAILS_ENV"]
when "staging"
  "go.staging"
else
  "go"
end
