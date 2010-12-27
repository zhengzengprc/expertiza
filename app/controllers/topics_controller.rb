class TopicsController < ApplicationController
  #def index
   # @topics = Topic.all
  #end
  #before_filter :login_required, :except => [:index, :show]
  #before_filter :admin_required
  def show
    @topic = Topic.find(params[:id])
    session[:topic_id]= @topic.id
  end
  
  def new
    @topic = Topic.new
    @post = Post.new
  end
  
  #def create
  #  @topic = Topic.new(params[:topic])
  #  if @topic.save
  #    flash[:notice] = "Successfully created topic."
  #    redirect_to @topic
  #  else
  #    render :action => 'new'
  #  end
  #end
  def create
  puts session[:user].name
  puts session[:forum_id]
  @topic = Topic.new(params[:topic])
  @topic.forum_id=session[:forum_id]
  @topic.user_id=session[:user].id
  @topic.last_poster_name=session[:user].name
  session[:topic_id]=@topic.id
  puts @topic.forum_id
  if @topic.save
    @post = Post.new(params[:content])
    @post.topic_id= session[:topic_id]
    @post.user_id= session[:user].id
    puts session[:topic_id]
    puts session[:user].name
    
    if @post.save
      puts " error here"
      #puts user.id
      #@topic = Topic.find(@post.topic_id)
      @topic.update_attributes(:last_poster_id => session[:user].id, :last_poster_name => session[:user].name, :last_post_at => Time.now)
      flash[:notice] = "Successfully created topic."
      #redirect_to "/forums/index"
      #redirect_to "/forums/#{@topic.forum_id}"
      redirect_to :controller => "forums", :action => :show, :forum => @topic.forum_id
    else
      redirect :action => :new
    end
  else
    render :action => :new
  end
end

  
  
  def edit
    @topic = Topic.find(params[:id])
  end
  
  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Successfully updated topic."
      redirect_to "/forums/#{@topic.forum_id}"
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    flash[:notice] = "Successfully destroyed topic."
    redirect_to :controller => 'forums', :action => :show, :forum => @topic.forum_id
  end
end
