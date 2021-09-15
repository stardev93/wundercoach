class Account < ApplicationRecord
  # Updates Sofort.com access. Only allows complete data access data
  class UpdateSofort < Trailblazer::Operation
    step Contract::Build(constant: SofortForm)
    step Contract::Validate()
    step Contract::Persist()
  end
end
