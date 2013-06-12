class Change < ActiveRecord::Base

  ESTIMATE_CHANGED = 'estimate'
  STATUS_LOCATION_CHANGE = 'status_location'
  ADDED = 'added'
  REMOVED = 'removed'

  attr_accessible :action,
                  :associated_story_pid,
                  :associated_subtask_pid,
                  :location,
                  :newValue,
                  :oldValue,
                  :pid,
                  :board_pid,
                  :sprint_pid,
                  :status,
                  :is_done,
                  :time

  belongs_to :sprint
  belongs_to :board
end
