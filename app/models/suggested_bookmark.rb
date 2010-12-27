class SuggestedBookmark < ActiveRecord::Base
  belongs_to :sign_up_topic
  belongs_to :user
  validates_presence_of :bookmark_link
  validates_presence_of :title
  
  def self.find_bookmark_links_for_topics(topic_id)
    SuggestedBookmark.find_by_sql("SELECT bookmark_link FROM suggested_bookmarks sb WHERE sb.sign_up_topic_id =" + topic_id);    
  end
  def self.find_bookmarks_for_topics(topic_id)
    SuggestedBookmark.find_by_sql("SELECT t.topic_name, sb.id, sb.sign_up_topic_id, sb.bookmark_link, sb.title, sb.user_id FROM suggested_bookmarks sb, sign_up_topics t WHERE sb.sign_up_topic_id =" + topic_id +" AND t.id="+ topic_id);    
  end
  
end
