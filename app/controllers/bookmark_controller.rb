class BookmarkController < ApplicationController
  
  def add_bookmark
    if params[:method] == "post"
      if(!params[:bookmark_title].strip)
        flash[:error] = "Please give the bookmark a title."
        return
      end
      if (!params[:url].strip)
        #can perform some string processing here to validate the url suggested.
        flash[:error] = "Please give the bookmark a valid url."
        return
      end
      flag=0
      @bookmarks_list=SuggestedBookmark.find_bookmark_links_for_topics session[:topicid]
      i=0
      for i in 0..@bookmarks_list.length-1
        if @bookmarks_list[i].bookmark_link==params[:url]   #cannot submit two bookmarks which have the same links
          flag=1;
        end
      end
      if flag==0
        @sugg_bookmark= SuggestedBookmark.new
        @sugg_bookmark.sign_up_topic_id=session[:topicid]
        @sugg_bookmark.user_id= session[:user].id
        @sugg_bookmark.title= params[:bookmark_title]
        @sugg_bookmark.bookmark_link=params[:url]
        
        if @sugg_bookmark.save   #Inserting into the suggested_bookmarks table
          flash[:notice] = "Bookmark is successfully submitted!"    
        else
          flash[:error] = "Some error occurred while saving the bookmark. Please try again."
        end
      else
        flash[:notice] = "Bookmark was already submitted!"
      end
      redirect_to :action=>'list_bookmarks', :id=>session[:topicid]
    end
    
  end
  
  
  def list_bookmarks
    @flag1=0
    i=0
    
    @signed_up_teams=SignedUpUser.find_signed_up_user params[:id]
    length=@signed_up_teams.length
    
    if length ==0
      @flag1=0
    else
      
      for i in 0..length-1
        @userid=(session[:user].id).to_s   #getting the userid of the logged in user
        @team=TeamsUser.find_teamid_for_userid @userid   #getting the teamid for the logged in user
        creatorStr = @signed_up_teams[i].creator_id      #getting the teamid of all teams that have signed up for the topic
        teamIdStr = @team[0].team_id 
        teamIdStr = teamIdStr.to_s
        if creatorStr == teamIdStr         #checking to see if the logged in user belongs to the same team as the signed up team for the topic
          @flag1=1;                        #only signed up users for the topic can rate the bookmarks and view bookmark ratings for that topic
        end
      end
    end
    
    @bookmarks_list=SuggestedBookmark.find_bookmarks_for_topics params[:id]
  end
  
  
  def rate_bookmark
    @flag2=0
    @userid=(session[:user].id).to_s
    @team=TeamsUser.find_teamid_for_userid @userid
    @bookmark_rating= BookmarkRating.new
    @bookmark_rating.suggested_bookmark_id=params[:id]
    @bookmark_rating.rating=params[:rating]
    @bookmark_rating.team_id=@team[0].team_id 
    if @bookmark_rating.save                          #Inserting into the bookmark_ratings table
      flash[:notice] = "Bookmark Rating is successfully submitted!"    
      @flag2=1
    else
      flash[:error] = "Some error occurred while saving the rating for the bookmark. Please try again."
    end
    redirect_to :action=>'list_bookmarks', :id=>session[:topicid]
  end
  
  
  def existing_rating
    @averagerating=BookmarkRating.find_ratings_for_bookmarks params[:id]  #getting all the ratings for a particular bookmark
    j=0
    sum = 0
    length = @averagerating.length
    if length==0
      @averagerating = 0
    else
      for j in 0..length-1
        sum = sum + @averagerating[j].rating        
      end
      @averagerating = sum/length              #Calculating the average rating for a bookmark
    end
  end
end
