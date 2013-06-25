class WorkActivity < ActiveRecord::Base

  belongs_to :assignee
  belongs_to :board
  belongs_to :sprint

  has_many :sprint_stories

end
