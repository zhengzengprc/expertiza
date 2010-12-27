class MicrotaskParticipant < ActiveRecord::Base

  belongs_to :microtask, :class_name => 'Microtask', :foreign_key => 'microtaskid'
  #  has_many :review_mappings, :class_name => 'ParticipantReviewResponseMap', :foreign_key => 'reviewee_id'
  belongs_to :user
  def get_files(directory)

    files_list = Dir[directory + "/*"]
    files = Array.new
    for file in files_list
      if File.directory?(file) then
        dir_files = get_files(file)
        dir_files.each{|f| files << f}
      end
      files << file
    end

    return files
    #return directory

  end

  def get_path
    #path = self.microtask.get_path + "/"+ self.directory_num.to_s
    #path = self.microtask.get_path + "/"
    path = RAILS_ROOT + "/pg_data/" + User.find(self.microtask.instructor_id).name  + "/" + User.find(self.userid).name + "/microtasks/"
    return path
  end

  def get_files(directory)

    files_list = Dir[directory + "/*"]
    files = Array.new
    for file in files_list
      if File.directory?(file) then
        dir_files = get_files(file)
        dir_files.each{|f| files << f}
      end
      files << file
    end

    return files
    #return directory

  end
end
