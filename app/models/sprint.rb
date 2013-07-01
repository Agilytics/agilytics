class Sprint < ActiveRecord::Base

  attr_accessible :closed,
                  :start_date,
                  :end_date,
                  :have_all_changes,
                  :have_processed_all_changes,
                  :name,
                  :pid,

                  :init_velocity,
                  :added_velocity,
                  :estimate_changed_velocity,
                  :total_velocity,

                  :init_commitment,
                  :added_commitment,
                  :estimate_changed,
                  :total_commitment,

                  :missed_init_commitment,
                  :missed_added_commitment,
                  :missed_estimate_changed,
                  :missed_total_commitment


  has_many :changes
  has_many :sprint_stories
  has_many :stories, :through => :sprint_stories
  has_many :assignees, :through => :sprint_stories
  has_many :reporters, :through => :sprint_stories
  has_many :work_activities

  belongs_to :board
end