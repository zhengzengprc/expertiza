class Follower < ActiveRecord::Base

def self.get_friends(user)
  # get all who this user follows
  friends = find(:all, :conditions => ["name = ?", user.name])
end



end
