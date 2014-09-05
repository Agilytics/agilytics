class Sprint < ActiveRecord::Base

  attr_accessible :name,
                  :pid,
                  :sprint_id,
                  :to_analyze,

                  :cost,

                  :closed,
                  :start_date,
                  :end_date,
                  :closed_date,

                  :init_velocity,
                  :added_velocity,
                  :estimate_changed_velocity,
                  :total_velocity,
                  :removed_added_velocity,
                  :removed_committed_velocity,

                  :init_commitment,
                  :added_commitment,
                  :estimate_changed,
                  :total_commitment,

                  :missed_init_commitment,
                  :missed_added_commitment,
                  :missed_estimate_changed,
                  :missed_total_commitment

  has_many :sprint_stories
  has_many :stories, :through => :sprint_stories
  has_many :assignees, :through => :sprint_stories
  has_many :reporters, :through => :sprint_stories

  belongs_to :board
  belongs_to :release
end