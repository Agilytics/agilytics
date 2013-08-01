class SprintStory < ActiveRecord::Base

  def initialization
    self.size = 0
  end

  attr_accessible :acuity,
                :is_done,
                :location,
                :size,
                :init_size,
                :init_date,
                :status,
                :was_added,
                :was_removed,
                :pid,
                :is_initialized
                :story_id
                :sprint_id
                :assignee_id
                :reporter_id
                :work_activity_id
  has_many :changes
  belongs_to :story
  belongs_to :sprint
  belongs_to :assignee
  belongs_to :reporter
  belongs_to :work_activity

  def set_if_added_or_removed(change)
    if !! change.if_of_action(Change::ADDED)
      self.was_added = true
      self.was_removed = false
    elsif !! change.action.index(Change::REMOVED)
      self.was_removed = true
    end
  end

  def set_is_story_done(change)
    if !!change.if_of_action(Change::STATUS_LOCATION_CHANGE)
      # assumption being that the events are happening in order of time, last status is current
      self.is_done = change.is_done
      change.new_value
    end
  end

  def set_size_of_story(change)
    if !!change.if_of_action(Change::INITIAL_ESTIMATE)
      self.init_size = change.new_value.to_i
      self.size = self.init_size
      self.is_initialized = true

    elsif change.if_of_action(Change::ESTIMATE_CHANGED)
      self.size = 0 unless self.size
      self.size = change.new_value.to_i
      unless self.is_initialized
        self.init_size = 0
        self.is_initialized = true
      end
    end
  end


end




