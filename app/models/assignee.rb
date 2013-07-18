class Assignee < AgileUser
  has_many :work_activities
  has_many :sprint_stories
  has_many :stories
  has_many :subtasks
end

