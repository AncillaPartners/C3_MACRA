class Response < ApplicationRecord
  has_many :response_errors, :dependent => :destroy
end
