class Change < ActiveRecord::Base

  def initialize
    super
    action = ''
  end


  INITIAL_ESTIMATE = 'initial_estimate'
  ESTIMATE_CHANGED = 'changed_estimate'
  STATUS_LOCATION_CHANGE = 'status_location'
  ADDED = 'added'
  REMOVED = 'removed'
  FINISHED = 'finished'
  REOPENED = 'reopened'
  NA = 'na'

  attr_accessible :action,
                  :associated_story_pid,
                  :associated_subtask_pid,
                  :location,
                  :new_value,
                  :current_story_value,
                  :pid,
                  :board_pid,
                  :sprint_pid,
                  :status,
                  :is_done,
                  :time

  belongs_to :sprint
  belongs_to :board
  belongs_to :sprint_story
  belongs_to :subtask

  def if_of_action(action)
    self.action.index(action)
  end

  def check_if_reopened(sprint_story)
    if(sprint_story.is_done && !self.is_done)
      self.action += Change::REOPENED
    end

  end

  def if_size_type_set(change, sprint)

    if change['statC']
      if self.time < sprint.start_date # before sprint started
        # then set to the start date
        self.time = sprint.start_date
        self.action += Change::INITIAL_ESTIMATE
      else
        self.action += Change::ESTIMATE_CHANGED
      end

      if change['statC']['noStatsValue']
          self.new_value = 0

      elsif change['statC']['newValue']
          self.new_value = change['statC']['newValue']
      end

    end

  end

  def if_done_set(change)
    if change['column']
      self.action += Change::STATUS_LOCATION_CHANGE
      self.location = change['column']['newStatus']

      if(!change['column']['notDone'])
        self.is_done = true
        self.action += Change::FINISHED
      end
    end
  end

  def if_added_removed_set(change, sprint)
    if self.time > sprint.start_date # after sprint started
      if change['added'] == true
        self.action += Change::ADDED

      elsif change['added'] == false
        self.action += Change::REMOVED
      end
    end
  end

  def determine_type_and_apply(change, sprint)
    self.action = '' unless self.action
    if_done_set(change)
    if_added_removed_set(change, sprint)
    if_size_type_set(change, sprint)
  end

end
