class Follower < ActiveRecord::Base

def self.get_friends(user)
  # get all who this user follows
  friends = find(:all, :conditions => ["name = ?", user.name])
#  friend_ids = []
#  friends.each {|f| friend_ids << f.followeruserid}
#  #puts "in follower: #{friend_ids}"
#  # go get those users from the database
#  friends = User.find(friend_ids)
end

#def self.get_notfriends(user)
#  friends = find(:all, :conditions => ["name == ?", user.name])
#  friend_ids = []
#  friends.each {|f| friend_ids << f.followeruserid}
#  # go get those users from the database
#  friends = User.find(!friend_ids)
#end


end
