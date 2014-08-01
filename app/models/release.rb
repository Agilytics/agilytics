class Release < ActiveRecord::Base

  attr_accessible :name,
                  :description,
                  :release_date

  has_many :sprints
  belongs_to :site
end