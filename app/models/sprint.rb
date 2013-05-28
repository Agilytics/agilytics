class Sprint
  include Mongoid::Document

  field :jid, type: Integer
  field :name, type: String
  field :closed, type: Boolean
  field :velocity, type: Integer
  field :have_all_changes, type: Boolean, default: false
  field :have_processed_all_changes, type: Boolean, default: false
  field :start_date, type: DateTime


  embeds_one :change_set
  embedded_in :board
  embeds_many :stories


end