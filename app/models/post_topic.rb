class PostTopic < ActiveRecord::Base
  # so that we can do <a post>.post_topic.topicname" ...
  has_many :posts
  
  validates_presence_of :topicname
  
  # NOTE: posts are associated with a topic: by default posts get a topic
  # id = -1. This is the general "no topic assigned" category
  
  # when one deletes a topic, all the posts of that topic must be moved
  # into the "no topic" topic
  def self.delete_topic(id)
    # when a topic is deleted, take all the posts of that topic and give them "topic_id = 1",
    # thereby telling the application that these posts are topic-less
    Post.find(:all, :conditions => ["topic_id = ?",id]).each do |p|
      p.topic_id = 1
      p.save
    end
    # delete the topic in question
    PostTopic.find(id).destroy
  end
  
  # returns a list of topics having a search string
  def self.find_some_topics(search)
    search_condition = "%" + search + "%"
    # find all topics containing the search term
    posts = find(:all, 
               :conditions => ["topicname LIKE ?", search_condition,],
               :order => "updated_at DESC")
  end
  
  # returns a list of posts in _all_ topics, all containing some particular string, nicely threaded 
  # the format of the threading is <all topic 1 threads> + <all topic 2 threads> + ... <all topic n threads> 
  def self.find_some_threads(search)
    # get all the topics
    topics = find(:all, :order => "updated_at DESC")
    
    # grab the posts that are not associated with any topic
    posts = Post.find_some_threads(search,1)   # '-1' is the topic_id of posts belonging to no topic
    
    # ...add in the other posts that _are_ associated with topics
    topics.each do |t|
      posts += Post.find_some_threads(search, t.id)   # for each topic, concatenate that topic's posts to the 'posts' variable
    end
    return posts
  end
  
  # for the rest of the functions, make it so that I call the Post member functions
  
  #  # returns a list of all posts, nicely threaded
  #  def self.get_all_threads
  #    # get all the posts (sans replies)
  #    posts = Post.find_all_posts
  #    
  #    thread_order = []
  #    posts.each do |post|
  #      # save the id of 'post'
  #      thread_order << post.id
  #      # find the replies to 'post'
  #      replies = Post.find_all_replies(post)
  #      # save the replies to 'post'
  #      replies.each {|reply| thread_order << reply.id}
  #      #puts "replies: #{replies.count}, thread_order: #{thread_order}"
  #    end
  #    #puts "final thread_order #{thread_order}"  # a display to check the order
  #    
  #    # grab all the posts with their replies, then map them back to the right order (because 'find' returns a default order)
  #    # this makes life easy for the html
  #    p = Post.find(thread_order)    
  #    threads = thread_order.map{|id| p.detect{|each| each.id == id}}
  #  end
  #  
  #  # a search method for time-sorted posts (e.g. posts with no parents)
  #  def self.find_all_posts
  #    Post.find(:all, :conditions => ["parentpost = ?",0], :order => "updated_at DESC")
  #  end
  #  
  #  # a search method for time-sorted replies to a particular post
  #  def self.find_all_replies(post)
  #    Post.find(:all, :conditions => ["parentpost = ?", post.id], :order => "updated_at ASC")
  #  end
  #  
  
  #  # a search method for time-sorted _threads_ containing a particular word (in either the name or the posttext) 
  #  # e.g. if the search term is in either the post or its replies, the whole thread is outputted 
  #  def self.find_all_in_threads(search)
  #    search_condition = "%" + search + "%"
  #    # find all posts with the search term in the name or posttext
  #    posts = find(:all, 
  #                     :conditions => ['(posttext LIKE ? OR name LIKE ?) AND parentpost = ?', search_condition, search_condition, 0],
  #                     :order => "updated_at DESC")
  #    # find all the replies with the search term in the name or posttext
  #    replies = find(:all,
  #                     :conditions => ['(posttext LIKE ? OR name LIKE ?) AND parentpost >= ?', search_condition, search_condition, 0],
  #                     :order => "updated_at DESC")
  #    # get lists of post ids, and ids for _parents_ of replies                         
  #    post_ids = []
  #    reply_ids = []
  #    posts.each {|p| post_ids << p.id}
  #    replies.each {|r| reply_ids << r.parentpost}
  #    #puts "got here............#{post_ids}, and #{reply_ids}"
  #    # join these lists
  #    posts_and_replies = post_ids | reply_ids
  #    posts_and_replies.delete(0)               # delete any items labeled '0', as this is the parent id of a bona-fide post
  #    # this join lists has every post and every parent of a post that has the search term. 
  #    # find all those posts: they are the starting point for a _complete_ list of threaded results:
  #    # this is useful in that for replies with the search term, both their parents, and their fellow replies
  #    # may now be listed in order
  #    #puts "parent_ids: #{posts_and_replies.each}"
  #    Post.find(posts_and_replies)
  #  end
  
  
end
