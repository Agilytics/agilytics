class JiraUser
  include Mongoid::Document

  field :jid, type: String

  field :name, type: String
  field :display_name, type: String
  field :email_address, type: String

  embedded_in :story
end