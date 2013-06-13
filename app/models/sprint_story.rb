class SprintStory < ActiveRecord::Base

  attr_accessible :acuity,
                :done
                :location,
                :size ,
                :init_size, #default to zero
                :init_date, #not added
                :status,
                :was_added, #not added
                :was_removed, #not added
                :pid,
                :is_initialized # not added boolean

  belongs_to :story
  belongs_to :sprint
end




