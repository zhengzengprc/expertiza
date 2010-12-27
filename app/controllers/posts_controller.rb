class PostsController < ApplicationController
  #def index
   # @posts = Post.all
  #end
  
  def show
    @post = Post.find(params[:id])
    
  end
  #before_filter :login_required
  def new
    @post = Post.new
  end
  
  #def create
   # @post = Post.new(params[:post])
    #if @post.save
     # flash[:notice] = "Successfully created post."
     # redirect_to @post
    #else
    #  render :action => 'new'
    #end
  #end
  #def create
  #@post = Post.new(:content => params[:post][:content], :topic_id => params[:post][:topic_id], :user_id => current_user.id)
  #if @post.save
   # flash[:notice] = "Successfully created post."
   # redirect_to "/topics/#{@post.topic_id}"
  #else
   # render :action => 'new'
  #end
#end

def create
  #@post = Post.new(:content => params[:post][:content], :topic_id => params[:post][:topic_id], :user_id => current_user.id)
  @post = Post.new(params[:post])
  @post.topic_id= session[:topic_id]
  @post.user_id= session[:user].id
  @post.last_poster_name= session[:user].name
  puts session[:topic_id]
  puts session[:user].name
  puts session[:user].id
   
  if @post.save
    @topic = Topic.find(@post.topic_id)
    @topic.update_attributes(:last_poster_id => session[:user].name, :last_poster_name => session[:user].name, :last_post_at => Time.now)
    flash[:notice] = "Successfully created post."
    redirect_to "/topics/show/#{@post.topic_id}"
    #render :action => 'show'
  else
    render :action => 'new'
  end
end

def cheerup
  
  @post= Post.find(params[:postt])
  puts"The ratings are for cheerup"
  #puts @post.rating
  puts session[:total]
  puts "after find"
  if @post.user_id== session[:user].id
   flash[:error]="You cannot cheer your own posts"
  puts "after user id value"
  else
  puts "i'am in the else statement"
  @post.cheers=@post.cheers+1
  session[:total]= @post.cheers
  #@post.rating= @post.rating + session[:total]
  #@post.rating=@post.rating+1
  flash[:warning]='You have cheered up the post'
  
  end
  @post.save
  
   respond_to do |format|
       # flash[:notice] = 'You cheered up the post.'
        format.html{redirect_to "/topics/show/#{@post.topic_id}"}
        format.xml {head :ok}
        
   end
end

# cheerdown functionality
def cheerdown
  @post= Post.find(params[:postth])
  @user= User.find(session[:user].id)
  puts " the user id is "
  puts @user.id
  puts " the userid associated with the post is"
   puts @post.user_id
  puts @post.topic_id
  puts @post.id    #2
  puts @post.user_id   #1
  puts session[:user_id]
  puts "after find"
  if @post.user_id== session[:user].id
    flash[:error]='You cannot uncheer your own posts'
  puts "after user id value"
  
  else if(@post.cheers==0)
  flash[:error]= 'Cannot uncheer when cheers are 0'
  
  else
  @post.cheers=@post.cheers-1
  #@post.rating=@post.rating-1
   
  end
  end
  @post.save
   respond_to do |format|
        #flash[:notice] = 'You uncheered the post.'
        format.html{redirect_to "/topics/show/#{@post.topic_id}"}
        format.xml {head :ok}
        
   end
end


def edit
   @post = Post.find(params[:post])
  #admin_or_owner_required(@post.user.id)
end

def update
  @post = Post.find(params[:post])
  #admin_or_owner_required(@post.user.id)
  if @post.update_attributes(params[:post])
    @topic = Topic.find(@post.topic_id)
    @topic.update_attributes(:last_poster_id => session[:user].id, :last_post_at => Time.now)
    flash[:notice] = "Successfully updated post."
    redirect_to "/topics/#{@post.topic_id}"
  else
    render :action => 'edit'
  end
end

def destroy
  @post = Post.find(params[:post])
  #admin_or_owner_required(@post.user.id)
  @post.destroy
  flash[:notice] = "Successfully destroyed post."
  redirect_to "/forums/index"
end
end
