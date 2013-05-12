class Changeset
  include Mongoid::Document
  embedded_in :sprint
end