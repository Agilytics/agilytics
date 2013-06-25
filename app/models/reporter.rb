class Reporter < AgileUser
  has_many :sprint_stories
  has_many :stories
end
