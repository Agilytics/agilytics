class Board < ActiveRecord::Base

  attr_accessible :name,
                  :pid,
                  :to_analyze,
                  :to_analyze_backlog,
                  :last_updated,

                  :run_rate_cost

  has_many :sprints
  has_many :releases
  belongs_to :site
  has_and_belongs_to_many :categories

end
