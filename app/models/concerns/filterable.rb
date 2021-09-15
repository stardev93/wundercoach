# Makes collections filterable without bloating controllers
# copied from http://www.justinweiss.com/articles/search-and-filter-rails-models-without-bloating-your-controller/
module Filterable
  extend ActiveSupport::Concern
  # adds filter method
  module ClassMethods
    def filter(filtering_params)
      results = all
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present? && value != ['']
      end
      results
    end
  end
end
