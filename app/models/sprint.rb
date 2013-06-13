class Sprint < ActiveRecord::Base

  attr_accessible :closed,
                  :end_date,
                  :have_all_changes,
                  :have_processed_all_changes,
                  :name,
                  :pid,
                  :start_date,
                  :velocity

  has_many :changes
  #has_many :sprint_stories
  belongs_to :board

end