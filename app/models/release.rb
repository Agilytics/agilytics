class Release < ActiveRecord::Base

  attr_accessible :name,
                  :description,
                  :release_date,

                  :cost,
                  :total_velocity

  has_many :sprints
  belongs_to :site
  belongs_to :board
end