class Board < ActiveRecord::Base
  attr_accessible :is_sprint_board,
                  :name,
                  :pid

  has_many :sprints
  has_many :stories
  has_many :changes
end
