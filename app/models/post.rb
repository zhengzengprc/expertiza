class Post < ActiveRecord::Base
  has_many :cheers
  
  validates_presence_of :posttext
  validates_presence_of :name
  validates_presence_of :parentpost
  
  # find and return the cheercount for this instance of the class (e.g. this post), remembering that each row
  # of the cheers DB corresponds to one user, and each user can have cheer and uncheer
  def get_cheercount
    sum = 0
    c = cheers.each {|cheer| sum += cheer.cheercount}
    return sum
  end
  
  def get_uncheercount
    sum = 0
    c = cheers.each {|cheer| sum += cheer.uncheercount}
    return sum
  end
  
  # find the number of cheers/uncheers per user: returns an array of post objects
  def self.cheers_per_user
    # thank God for this line!
    # 1) join the 'cheers' table to the posts table
    # 2) group that join according to 'posts.name', so that we can sum a group from the 'cheercount' and 'uncheercount' columns
    # 3) select entries a) by 'posts.name', summing their respective 'cheercounts' and 'uncheercounts', and saving those sums in new variables
    Post.all(:joins => :cheers,
             :group => "posts.name",
             :select => "posts.name, SUM(cheers.cheercount) AS cheer_sum, SUM(cheers.uncheercount) AS uncheer_sum",
             :order => "cheer_sum DESC")
    
    #     http://stackoverflow.com/questions/1980409/rails-join-three-models-and-compute-the-sum-of-a-column
    #     Property.all  :select => "properties.name, rents.month, SUM(units.monthly_rent) AS rent_sum",
    #                        :joins => { :units => :rents },
    #                        :group => "properties.id, rents.month, rents.year"
  end
  
  # when one deletes a post, all the followers of that post get deleted too
  def self.delete_post_or_thread(id)    
    # find the post and any replies it may have, then delete them _and_ all the cheers associated with them
    posts = Post.find(:all, :conditions => ["id == ? OR parentpost == ?", id, id])
    posts.each do |p|
      cheers = Cheer.find(:all, :conditions => ["post_id == ?", p.id])
      cheers.each {|c| c.destroy}
      p.destroy
    end
    
  end
  
  ## cheer and uncheer posts
  # cheer a post
  def self.cheer_post(post_num, current_user)
    # this code must check that
    # - if (un)cheer already exists (each post gets only one row per user in the 'cheers' DB)
    # - only one cheer/uncheer per user per post
    # - user does not cheer own post 
    #post_selected = params[:id]
    post_selected = post_num
    post_creator = Post.find(post_selected).name
    #current_user = User.find(session[:name]).name
    
    # if the cheering user did not create this post
    if current_user != post_creator        
      # look for a _cheer_ on this post BY this user; if none found, create such cheer
      user_cheer = Cheer.find_or_create_by_post_id_and_name(:post_id => post_selected,    # search based on these first two terms
                                                                :name => current_user, 
                                                                :cheercount => 0,             # if the search was unsuccessful, create a new record, with initial values from _all_ terms
                                                                :uncheercount => 0)
      # NOTE: the above line will only create a new cheer if there _is not_ one in the DB, and when it does create a new cheer, all the values are zero
      # if this user had interacted with this post before (but not cheered it)
      puts "in cheer...... #{user_cheer.cheercount}"
      if user_cheer.cheercount == 0 
        user_cheer.cheercount = 1        # let him cheer
        user_cheer.save
        return "cheered"    # indicates everything is good
      else                               # send him packing!
        return "You already cheered this post!"
      end
      
    else        # he is not allowed to cheer his own post
      return "You can't cheer your own post!"                          # this string will be returned
    end
  end
  
  # uncheer a post
  def self.uncheer_post(post_num, current_user)
    # same as above
    post_selected = post_num
    post_creator = Post.find(post_selected).name
    
    # if the cheering user did not create this post
    if current_user != post_creator        
      # look for a _(un)cheer_ on this post BY this user; if none found, create an uncheer
      user_cheer = Cheer.find_or_create_by_post_id_and_name(:post_id => post_selected,    # search based on these first two terms
                                                                :name => current_user, 
                                                                :cheercount => 0,             # if the search was unsuccessful, create a new record, with initial values from _all_ terms
                                                                :uncheercount => 0)
      # if this user had interacted with this post before (but not uncheered it) 
      if user_cheer.uncheercount == 0 
        user_cheer.uncheercount = 1        # let him cheer
        user_cheer.save
        return "uncheered"
      else                               # send him packing!
        return "You already uncheered this post!"
      end
      
    else        # he is not allowed to cheer his own post
      return "You can't uncheer your own post!"
    end
  end
  
  
  # returns a list of all posts, nicely threaded
  def self.get_all_threads
    # get all the posts (sans replies)
    posts = Post.find_all_posts
    
    thread_order = []
    posts.each do |post|
      # save the id of 'post'
      thread_order << post.id
      # find the replies to 'post'
      replies = Post.find_all_replies(post)
      # save the replies to 'post'
      replies.each {|reply| thread_order << reply.id}
      #puts "replies: #{replies.count}, thread_order: #{thread_order}"
    end
    #puts "final thread_order #{thread_order}"  # a display to check the order
    
    # grab all the posts with their replies, then map them back to the right order (because 'find' returns a default order)
    # this makes life easy for the html
    p = Post.find(thread_order)    
    threads = thread_order.map{|id| p.detect{|each| each.id == id}}
  end
  
  # a search method for time-sorted posts (e.g. posts with no parents)
  def self.find_all_posts
    Post.find(:all, :conditions => ["parentpost == ?",0], :order => "updated_at DESC")
  end
  
  # a search method for time-sorted replies to a particular post
  def self.find_all_replies(post)
    Post.find(:all, :conditions => ["parentpost == ?", post.id], :order => "updated_at DESC")
  end
  
  
  # returns a list of posts, all containing some particular string, nicely threaded
  def self.find_some_threads(search)
    # get all the posts that either contain the search term, or their replies contain the search term
    posts = Post.find_all_in_threads(search) 
    thread_order = []
    posts.each do |post|
      # save the id of 'post'
      thread_order << post.id
      # find all the replies to 'post'
      replies = Post.find_all_replies(post)
      # save the replies to 'post'
      replies.each {|reply| thread_order << reply.id}
      #puts "replies: #{replies.count}, thread_order: #{thread_order}"
    end
    #puts "final thread_order #{thread_order}"  # a display to check the order
    
    # grab all the posts with their replies, then map them back to the right order (because 'find' returns a default order)
    # this makes life easy for the html
    p = Post.find(thread_order)    
    threads = thread_order.map{|id| p.detect{|each| each.id == id}}
  end
  
  # a search method for time-sorted _threads_ containing a particular word (in either the name or the posttext) 
  # e.g. if the search term is in either the post or its replies, the whole thread is outputted 
  def self.find_all_in_threads(search)
    search_condition = "%" + search + "%"
    # find all posts with the search term in the name or posttext
    posts = find(:all, 
                     :conditions => ['(posttext LIKE ? OR name LIKE ?) AND parentpost == ?', search_condition, search_condition, 0],
                     :order => "updated_at DESC")
    # find all the replies with the search term in the name or posttext
    replies = find(:all,
                     :conditions => ['(posttext LIKE ? OR name LIKE ?) AND parentpost >= ?', search_condition, search_condition, 0],
                     :order => "updated_at DESC")
    # get lists of post ids, and ids for _parents_ of replies                         
    post_ids = []
    reply_ids = []
    posts.each {|p| post_ids << p.id}
    replies.each {|r| reply_ids << r.parentpost}
    #puts "got here............#{post_ids}, and #{reply_ids}"
    # join these lists
    posts_and_replies = post_ids | reply_ids
    posts_and_replies.delete(0)               # delete any items labeled '0', as this is the parent id of a bona-fide post
    # this join lists has every post and every parent of a post that has the search term. 
    # find all those posts: they are the starting point for a _complete_ list of threaded results:
    # this is useful in that for replies with the search term, both their parents, and their fellow replies
    # may now be listed in order
    #puts "parent_ids: #{posts_and_replies.each}"
    Post.find(posts_and_replies)
  end
  
  ########################
  # the following is an atrocity, and with a nicely formated table we probably could have done it in a couple lines. se la vie
  
  # returns a list of posts _written by_ friends, nicely threaded
  def self.get_friends_threads(user)    
    # extract the ids of the input user's friends, then get a list of them from the 'users' table 
    friends = Follower.find(:all, :conditions => ["name == ?", user.name])
    friend_ids = []
    friends.each {|f| friend_ids << f.followeruserid}
    friend_ids << user.id              # let the user be his own friend
    friends = User.find(friend_ids)
    
    # get all the posts by friends, or whose replies are by friends
    posts = Post.find_friends_in_threads(friends)   # go find all the posts by friends. if a reply to post was by a friend, the parent, plus the rest of the thread is returned 
    thread_order = []
    posts.each do |post| 
      # save the id of 'post'
      thread_order << post.id
      # find all the replies to 'post'
      replies = Post.find_all_replies(post)
      # save the replies to 'post'
      replies.each {|reply| thread_order << reply.id}
      #puts "replies: #{replies.count}, thread_order: #{thread_order}"
    end
    #puts "final thread_order #{thread_order}"  # a display to check the order
    
    # grab all the posts with their replies, then map them back to the right order (because 'find' returns a default order)
    # this makes life easy for the html
    p = Post.find(thread_order)    
    threads = thread_order.map{|id| p.detect{|each| each.id == id}}
  end
  
  # a search method for time-sorted _threads_ containing friends 
  # e.g. if the friend is in the reply to a thread, the parent that spawned that thread is returned 
  def self.find_friends_in_threads(friends)
    
    posts = []
    replies = []
    friends.each do |f|
      # find all posts belonging to our friends
      posts += find(:all,           # NOTE: array1 + array2 = concatenation of array1 and array2
                  :conditions => ['name == ? AND parentpost == ?', f.name, 0],
                  :order => "updated_at DESC")
      # find all the replies for this user
      replies += find(:all,
                    :conditions => ['name == ? AND parentpost >= ?', f.name, 0],
                    :order => "updated_at DESC")
    end
    
    posts.each {|p| puts "...#{p.name}"}
    
    # get lists of post ids, and ids for _parents_ of replies                         
    post_ids = []
    reply_ids = []
    posts.each {|p| post_ids << p.id}
    replies.each {|r| reply_ids << r.parentpost}
    #puts "got here............#{post_ids}, and #{reply_ids}"
    # join these lists
    posts_and_replies = post_ids | reply_ids
    posts_and_replies.delete(0)               # delete any items labeled '0', as '0' is the parent id of a bona-fide post, NOT an actual post id
    # this join lists has every post and every parent of a post that has the search term. 
    # find all those posts: they are the starting point for a _complete_ list of threaded results:
    # this is useful in that for replies with the search term, both their parents, and their fellow replies
    # may now be listed in order
    #puts "parent_ids: #{posts_and_replies.each}"
    Post.find(posts_and_replies, :order => "updated_at DESC")
  end
  
  
  # some examples of searches
  # Person.find(:all, :conditions => [ "category IN (?)", categories], :limit => 50)
  # Post.find(:first, :conditions => { :status => 1, :active => 1 })
  # Person.find(1, :conditions => "administrator = 1", :order => "created_on DESC")
  # @applications = Application.find(:all, :order => sort_order('created_at'))
  # all = find(:all, :conditions => ["start >= ? and start <= ?", date.last_month.end_of_month, date.next_month.beginning_of_month], :order => :start)
  
end
