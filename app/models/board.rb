class Board < ActiveRecord::Base
  attr_accessible :name,
                  :pid,
                  :to_analyze

  has_many :sprints
end
