class Sprint
  include Mongoid::Document
  field :jid, type: Integer
  field :name, type: String
  field :closed, type: Boolean
  field :velocity, type: Integer

  field :start_date, type: DateTime


  embeds_one :changeset
  embedded_in :board
  embeds_many :stories
end