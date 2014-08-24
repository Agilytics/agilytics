class Tag < ActiveRecord::Base

  TYPE = 'type'
  LABEL = 'label'
  EPIC = 'epic'

  attr_accessible :name

  has_and_belongs_to_many :sprint_stories
  has_and_belongs_to_many :categories

end
