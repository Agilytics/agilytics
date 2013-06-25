class Sprint < ActiveRecord::Base

  attr_accessible :closed,
                  :start_date,
                  :end_date,
                  :have_all_changes,
                  :have_processed_all_changes,
                  :name,
                  :pid,
                  :velocity,
                  :init_velocity,
                  :total_velocity,
                  :estimate_changed_velocity,
                  :added_velocity,
                  :init_commitment,
                  :total_commitment

  has_many :changes
  has_many :sprint_stories
  has_many :stories, :through => :sprint_stories
  has_many :assignees, :through => :sprint_stories
  has_many :reporters, :through => :sprint_stories
  has_many :work_activities

  belongs_to :board
end