class Board
  include Mongoid::Document
  field :jid, type: Integer
  field :name, type: String
  embeds_many :sprints



end