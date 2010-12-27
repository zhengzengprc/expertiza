class BookmarkRating < ActiveRecord::Base
  
  validates_presence_of :rating
  validates_numericality_of :rating, :only_integer => true, :message => "can only be whole number."
  validates_inclusion_of :rating, :in => 1..5, :message => "can only be in the 1 to 5."
  
  def self.find_ratings_for_bookmarks(bookmark_id)
    BookmarkRating.find_by_sql("SELECT t.rating FROM bookmark_ratings t WHERE t.suggested_bookmark_id ="+ bookmark_id);    
  end
  
end
