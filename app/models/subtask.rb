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
  has_many :changes
  belongs_to :story
  belongs_to :assignee
  belongs_to :reporter
end
