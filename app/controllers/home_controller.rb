
class HomeController < ApplicationController
  
  def index
    # determine what type of user we are dealing with: [a nobody, a standard user, an admin]
    if !session[:name]                           # if there is no user
      @mode = -1                               # default the user mode to the 'a nobody' case
      @user = nil
    else                                             # if there is a user
      @mode = User.find(session[:name]).role_id    # find his role_id and make it available to the view
      @user = User.find(session[:name]).name
      #puts "mode: #{@mode}"
    end
    
    # base which posts are displayed by what the user searches (or doesn't search) for
    if params[:search].nil?                     # if there is no ':search' value
      
      @threads = Post.get_all_threads
      #--fetches 20 records
      @threads = @threads.paginate(:page => params[:page], :per_page => 20)
    else                                      # else find the ones he wants
      
      
      @threads = Post.find_some_threads(params[:search])
      @threads = @threads.paginate(:page => params[:page], :per_page => 20)
      
    end    
  end
  
  # show how many cheers/uncheers each user has
  def ratings
    # determine what type of user we are dealing with: [a nobody, a standard user, an admin]
    if !session[:name]                           # if there is no user
      @mode = -1                               # default the user mode to the 'a nobody' case
      @user = nil
    else                                             # if there is a user
      @mode = User.find(session[:name]).role_id    # find his role_id and make it available to the view
      @user = User.find(session[:name]).name
      #puts "mode: #{@mode}"
    end
    
    # grab a list of modified cheer objects: each object has a name, and the total
    # sum of 'cheercount' and 'uncheercount' as new instance variables 'cheer_sum' and
    # 'uncheer_sum'. a very, very cool little piece of SQL!
    #@ratings = Cheer.cheers_per_user
    @ratings = Post.cheers_per_user
    @ratings = @ratings.paginate(:page => params[:page], :per_page => 10) # include some pagination
  end
  
  # cheer a post
  def cheer
    # try to cheer the post: the return value indicates whether the cheer worked or not
    ret = Post.cheer_post(params[:id],User.find(session[:name]).name)
    # flash the response from the post class if the user was not allowed to cheer
    if ret != 'cheered' then flash[:notice] = ret end
    redirect_to :action => 'index'  
  end
  
  # uncheer a post
  def uncheer
    ret = Post.uncheer_post(params[:id],User.find(session[:name]).name)
    puts "yo ho ho ho#{ret}"
    if ret != 'uncheered' then flash[:notice] = ret end
    redirect_to :action => 'index'  
  end
  
  # for logged in users, this posts a comment
  def post
    # the html checks for the user, but we double check here
    unless !session[:name]
      puts ":name #{User.find(session[:name]).name}, :posttext => #{params[:new_post_text]}"
      # create a new post using the users information: because he entered it in the post box, their is no parent
      new_post = Post.new(:name => User.find(session[:name]).name, :posttext => params[:new_post_text], :parentpost => 0)
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
  
  # let the user reply
  def reply
    @user = User.find(session[:name])
    @post=Post.find_by_id(params[:id])
    
    @userreply = Post.new
    @userreply.parentpost = @post.id
    @userreply.name=@user.name
    @userreply.posttext=params[:posttext]
    if params[:posttext] !=nil
      @userreply.save
      redirect_to :action => 'index'
    end
  end
  
  # pick who you want as friends
  def friends
    @user = User.find(session[:name])
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
    if !session[:name]                           # if there is no user
      @mode = -1                               # default the user mode to the 'a nobody' case
      @user = nil
    else                                             # if there is a user
      @mode = User.find(session[:name]).role_id    # find his role_id and make it available to the view
      @user = User.find(session[:name]).name
      #puts "mode: #{@mode}"

      # get the threads
      user = User.find(session[:name])
      friends_posts = Post.get_friends_threads(user)
      @threads = friends_posts
      @threads = @threads.paginate(:page => params[:page], :per_page => 20)
    end
    
    # render the 'index' actions view, passing it only the friends information instead :)
    render :template => 'home/index' 
    #    
  end
  
  # login in is handled within 'admin_controller'
  
  # to log out
  def logout
    reset_session
    flash[:message] = 'Logged out'
    redirect_to :action => 'index'
  end
  #---Added for pagination
  
  
end
