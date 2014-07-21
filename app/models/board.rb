class Board < ActiveRecord::Base

  attr_accessible :name,
                  :pid,
                  :to_analyze,
                  :to_analyze_backlog,
                  :last_updated

  has_many :sprints
  belongs_to :site

end
