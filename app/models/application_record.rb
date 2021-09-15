# Abstract Record, from which all AR-Models should inherit
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
