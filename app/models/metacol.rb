class Metacol < ActiveRecord::Base
  attr_accessible :path, :sha, :state, :status, :user_id
  has_many :jobs
end
