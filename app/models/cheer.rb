class Cheer < ActiveRecord::Base
  belongs_to :post
  
  validates_presence_of :post_id
  validates_presence_of :cheercount
  validates_presence_of :uncheercount
  validates_presence_of :name
  
end
