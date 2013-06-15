class SprintStory < ActiveRecord::Base

  def initialization
    @size = 0
  end

  attr_accessible :acuity,
                :is_done,
                :location,
                :size ,
                :init_size,
                :init_date,
                :status,
                :was_added,
                :was_removed,
                :pid,
                :is_initialized

  belongs_to :story
  belongs_to :sprint

end




