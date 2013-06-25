class AgileUser < ActiveRecord::Base
  attr_accessible :display_name,
                  :email_address,
                  :name,
                  :pid
end

