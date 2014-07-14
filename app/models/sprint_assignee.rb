class SprintAssignee < ActiveRecord::Base

  belongs_to :assignee
  belongs_to :sprint

end
