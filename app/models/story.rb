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
                  :card_type

  belongs_to :board
#  has_many :sprint_stories
  has_many :subtasks, dependent: :destroy
  has_one :assignee, :class_name => 'AgileUser', :foreign_key => 'assignee_id'
  has_one :reporter, :class_name => 'AgileUser', :foreign_key => 'reporter_id'
end
