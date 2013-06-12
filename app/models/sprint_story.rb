class SprintStory < ActiveRecord::Base

  attr_accessible :acuity,
                :done
                :location,
                :size,
                :init_size,
                :status,
                :pid

  belongs_to :story
  belongs_to :sprint
end




