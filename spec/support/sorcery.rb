RSpec.configure do |config|
  config.include Sorcery::TestHelpers::Rails
  config.include Sorcery::TestHelpers::Rails::Controller
end