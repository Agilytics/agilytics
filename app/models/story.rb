class Story < ActiveRecord::Base

  STORY = 'story'
  BUG = 'bug'

  attr_accessible :acuity,
                  :create_date,
                  :pid,
                  :story_key,
                  :size,
                  :name,
                  :description,
                  :assignee_id,
                  :reporter_id,
                  :story_type,
                  :updated_at

  belongs_to :board
  has_many :sprint_stories
  has_many :subtasks, dependent: :destroy
  belongs_to :assignee
  belongs_to :reporter
end
