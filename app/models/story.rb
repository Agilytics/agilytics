class Story
  include Mongoid::Document

  field :jid, type: String

  field :is_initialized, type: Boolean, default: false
  field :init_date, type: DateTime

  field :was_added, type: Boolean, default: false
  field :was_removed, type: Boolean, default: false
  field :done, type: Boolean, default: false


  field :init_size, type: Integer, default: 0
  field :size, type: Integer

  embeds_one :assignee, class_name: 'JiraUser'
  embeds_one :reporter, class_name: 'JiraUser'

  embedded_in :sprint
end