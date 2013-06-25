class Subtask < ActiveRecord::Base
  attr_accessible :acuity,
                  :create_date,
                  :done,
                  :done_date,
                  :location,
                  :pid,
                  :size,
                  :status,
                  :assignee_id,
                  :reporter_id

  belongs_to :story
  has_one :assignee
  has_one :reporter
end
