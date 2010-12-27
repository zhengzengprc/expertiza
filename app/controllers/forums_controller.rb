class ForumsController < ApplicationController
 
  
  def index
    @forums = Forum.all
  end
  
  def show
    #puts params[:id]
    puts params[:forum]
    #puts params[:forum_id]
    @forum = Forum.find(params[:forum])
    session[:forum_id]=@forum.id
  end
  
  def new
    @forum = Forum.new
  end
  
  def create
    @forum = Forum.new(params[:forum])
    session[:forum_id]= @forum.id
    if @forum.save
      #params[:forum_id]=@forum.id
      flash[:notice] = "Successfully created forum."
      redirect_to "/forums/index"
    else
      render :action => 'new'
    end
  end
  
  def edit
    puts params[:forum]
    #puts params[:id]
    #puts params[:forum_id]
    @forum = Forum.find(params[:forum])
  end
  
  def update
    @forum = Forum.find(params[:forum])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = "Successfully updated forum."
      redirect_to @forum
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    puts params[:forum]
    @forum = Forum.find(params[:forum])
    @forum.destroy
    flash[:notice] = "Successfully destroyed forum."
    redirect_to :controller => 'forums', :action => :index
  end
end
