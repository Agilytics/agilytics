class Release < ActiveRecord::Base

  attr_accessible :name,
                  :description,
                  :release_date,

                  :cost

  has_many :sprints
  belongs_to :site
  belongs_to :board
end