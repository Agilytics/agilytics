class Category < ActiveRecord::Base

  attr_accessible :name

  has_and_belongs_to_many  :tags
  has_and_belongs_to_many :boards

end