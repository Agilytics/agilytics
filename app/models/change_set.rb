class ChangeSet
  include Mongoid::Document
  embedded_in :sprint
end