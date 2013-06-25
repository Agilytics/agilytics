class SprintAssignee < ActiveRecord::Base

  has_many :work_activities

  belongs_to :assignee
  belongs_to :sprint

end
