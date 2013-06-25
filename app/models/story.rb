class Story < ActiveRecord::Base

  STORY = 'story'
  BUG = 'bug'

  attr_accessible :acuity,
                  :create_date,
                  :done,
                  :done_date,
                  :location,
                  :pid,
                  :size,
                  :name,
                  :description,
                  :status,
                  :assignee_id,
                  :reporter_id,
                  :story_type

  belongs_to :board
  has_many :sprint_stories
  has_many :subtasks, dependent: :destroy
  belongs_to :assignee
  belongs_to :reporter
end
