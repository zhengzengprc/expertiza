class HomeController < ApplicationController
  
  ITEMS_PER_PAGE = 20
  
  def index
    # set up a flag so we know which topic we are in
    @topic_id = params[:topic_id]
    if (@topic_id != nil) then
      session[:current_topic_id] = @topic_id      
    end
    
    
    
    # determine what type of user we are dealing with
    @mode = session[:user].role_id      # check who this user is to adjust view options
    @user = session[:user].name
    
    # base which posts are displayed by what the user searches (or doesn't search) for
    if params[:search].nil?                     # if there is no ':search' value
      @threads = Post.get_all_threads(session[:current_topic_id])
      #--fetches ITEMS_PER_PAGE records
      @threads = @threads.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    else                                      # else find the ones he wants
      @threads = Post.find_some_threads(params[:search],session[:current_topic_id])
      @threads = @threads.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
      
    end    
  end
  
  # the first page a user comes to: shows the topics in this message board
  def topic
    @items_per_page = 5     # we are basically overwriting the ITEMS_PER_PAGE globals
    
    session[:current_topic_id] = 0
    @mode = session[:user].role_id
    @user = session[:user].name
    if params[:search].nil?                     # if there is no ':search' value
      @topics = PostTopic.find(:all)
      @topics = @topics.paginate(:page => params[:page], :per_page => @items_per_page)
    else                                        # there is a 'search' value
      # find all the topics containing the search string
      @match_topic = PostTopic.find_some_topics(params[:search])
      @match_topic = @match_topic.paginate(:page => params[:page], :per_page => @items_per_page)
      #NOTE: we find the threads associated with these topics in the HTML...it is easier that way
      
      # send down all the topics available for searching
      @topics = PostTopic.find(:all)
      
      # find all the threads containing the search string
      #@threads = PostTopic.find_some_threads(params[:search])
      #@topics = @topics.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    end    
  end
  
  def add_topic
    new_topic = PostTopic.new(:topicname => params[:new_topic_text])
    new_topic.save
    redirect_to :action => 'topic'
  end
  
  
  # show the ratings for the users accross _all_ the posts in the message board
  def ratings 
    # determine what type of user we are dealing with: [a nobody, a standard user, an admin]
    @mode = session[:user].role_id    # find his role_id and make it available to the view
    @user = session[:user].name
    
    # grab a list of modified cheer objects: each object has a name, and the total
    # sum of 'cheercount', 'uncheercount', 'best_post' as new instance variables 'cheer_sum',
    # 'uncheer_sum', and 'best_sum'. a very, very cool little piece of SQL!
    #@ratings = Cheer.cheers_per_user
    @cheer_ratings = Post.cheers_per_user
    @cheer_ratings = @cheer_ratings.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE) # include some pagination
  
    # get per-user ratings for the best replies
    @best_ratings = Post.bests_per_user
    @best_ratings = @best_ratings.paginate(:page=>params[:page],:per_page=>ITEMS_PER_PAGE)
    
    # a name for this set of ratings
    @rating_name = "User Ratings for All Topics"
  end
  
  # show the ratings for the users in a particular topic
  def ratings_per_topic
    # determine what type of user we are dealing with: [a nobody, a standard user, an admin]
    @mode = session[:user].role_id    # find his role_id and make it available to the view
    @user = session[:user].name
    
    # grab the topic the user is currently viewing
    topic_id = session[:current_topic_id]
    
    # grab a list of modified cheer objects associated only with this topic: each object has a name, and the total
    # sum of 'cheercount', 'uncheercount', 'best_post' as new instance variables 'cheer_sum',
    # 'uncheer_sum', and 'best_sum'. a very, very cool little piece of SQL!
    #@ratings = Cheer.cheers_per_user
    @cheer_ratings = Post.cheers_per_user_by_topic(topic_id)
    @cheer_ratings = @cheer_ratings.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE) # include some pagination
  
    # get per-user ratings for the best replies
    @best_ratings = Post.bests_per_user_by_topic(topic_id)
    @best_ratings = @best_ratings.paginate(:page=>params[:page],:per_page=>ITEMS_PER_PAGE)
    
    # a name for this set of ratings
    @rating_name = "User Ratings for Topic '" + PostTopic.find(topic_id).topicname + "'"
    
    # render this set of ratings for a particular topic in the default 'ratings' view.
    render :action => 'home/ratings'
  end
  
  # cheer a post
  def cheer
    # try to cheer the post: the return value indicates whether the cheer worked or not
    ret = Post.cheer_post(params[:id],session[:user].name)
    # flash the response from the post class if the user was not allowed to cheer
    if ret != 'cheered' then flash[:notice] = ret end
    redirect_to :action => 'index'  
  end
  
  # uncheer a post
  def uncheer
    ret = Post.uncheer_post(params[:id],session[:user].name)
    if ret != 'uncheered' then flash[:notice] = ret end
    redirect_to :action => 'index'  
  end
  
  # make post 'best' post
  def best
    # 'best' a post
    ret = Post.set_best(params[:id])
    redirect_to :action => 'index'  
  end
  
  # for logged in users, this posts a comment
  def post
    puts session[:current_topic_id]
    # the html checks for the user, but we double check here
    unless !session[:user]
      #puts ":name #{session[:user].name}, :posttext => #{params[:new_post_text]}"
      # create a new post using the users information: because he entered it in the post box, their is no parent
      new_post = Post.new(:name => session[:user].name, :posttext => params[:new_post_text], :parentpost => 0, :topic_id => session[:current_topic_id])
      new_post.save
    end
    redirect_to :action => 'index'
  end
  
  # delete a post (admins only)
  def delete
    # <we should add a prompt, there is no checking here!>
    Post.delete_post_or_thread(params[:id])
    redirect_to :action => 'index'
  end
  
  # delete a topic (admins only)
  def delete_topic
    # <we should add a prompt, there is no checking here!>
    PostTopic.delete_topic(params[:topic_id])
    redirect_to :action => 'topic'
  end
  
  # let the user reply
  def reply
    @user = session[:user]
    @post=Post.find_by_id(params[:id])
    
    @userreply = Post.new
    @userreply.parentpost = @post.id
    @userreply.name=@user.name
    @userreply.posttext=params[:posttext]
    @userreply.topic_id = session[:current_topic_id]
    if params[:posttext] !=nil
      @userreply.save
      redirect_to :action => 'index'
    end
  end
  
  # pick who you want as friends
  def friends
    @user = session[:user]
    puts "...#{@user}"
    @all_users = User.find(:all)              # get all the possible users
    @friends = Follower.get_friends(@user)    # go grab the people '@user' is friends with (e.g. is following), NOTE that this is not a list of 'users'
    friend_ids = []
    @friends.each {|f| friend_ids << f.followeruserid}
    
    friend_names = User.find(friend_ids)#.each.name
    #Post.find_all_friends_posts(friend_names)
    # the above is too hard for right now! come back and solve that problem later...
  end
  
  # view your friends
  def viewfriends
    # determine what type of user we are dealing with: [a nobody, a standard user, an admin]
    #    if !session[:name]                           # if there is no user
    #      @mode = -1                               # default the user mode to the 'a nobody' case
    #      @user = nil
    #    else                                             # if there is a user
    @mode = session[:user].role_id    # find his role_id and make it available to the view
    @user = session[:user].name
    #puts "mode: #{@mode}"
    
    # get the threads
    user = session[:user]
    @threads = Post.get_friends_threads(user,session[:current_topic_id])
    @threads = @threads.paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    #    end
    
    # render the 'index' actions view, passing it only the friends information instead :)
    render :template => 'home/index' 
    #    
  end
  
  # login in is handled within 'admin_controller'
  
  #  # to log out
  #  def logout
  #    reset_session
  #    flash[:message] = 'Logged out'
  #    redirect_to :action => 'index'
  #  end
  #  #---Added for pagination
  
  def change_topic    
    if params[:a].include?('1')
      puts params[:a]
      if params[:topic] and params[:activated] and params[:topic]!= 1                     
        params[:activated].each {|key,value|                    
          if value.eql?("1")                                    
            curr_post = Post.find(:first, :conditions => ['id = ?',key])                                      
            curr_post.topic_id = params[:topic] 
            curr_post.save                     
          end }      
      end
    elsif params[:a].include?('2')
      puts params[:a]
      if params[:activated]
        params[:activated].each {|key,value|
          if value.eql?("1")
            curr_post = Post.find(:first, :conditions => ['id = ?',key]) 
            curr_post.parentpost = 0
            curr_post.save
          end }
      end
    end
    redirect_to :action => 'index'  
  end
  
end
