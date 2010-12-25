class DocumentsController < ApplicationController
  before_filter :setup
  before_filter :gauthorize, :except => :index
 # before_filter :controler => 'admins', :action => 'gdoc_login'
  
    
  def index
    if not params[:folder_id]
      #Display all files and root folders
      @documents = @account.files
      @folders = @account.folders.select{|f| !f.parent } #display only root folders
      session[:folder_id] = nil
    else
      #Display only files and folders contained by folder_id
      @folder = Folder.find(@account, {:id => params[:folder_id]})
      @documents = @folder.files
      @folders = @folder.sub_folders
      session[:folder_id] = params[:folder_id]
    end
  end
  
  def view
    @document = BaseObject.find(@account, {:id => params[:doc_id]})
      @get_id = @document.id.match(/:(.+?)$/)[1]
  end
  
  def download
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    send_data @document.get_content(params[:type]), :disposition => 'inline', :filename => "#{@document.title}.#{params[:type]}"
  end
  
  def save
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    @document.title = params[:title]
    @document.save
    redirect_to :action => :view, :doc_id => @document.id
  end
  
  def save_content
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    @document.put_content(params[:content])
    redirect_to :action => :view, :doc_id => @document.id
  end
  
  def edit
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    #@document = Document.find(@service, {:id => @doc_id})
  end
  
#  def edit_iframe
#      @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
#        flash[:notice] = @document.to_iframe
#        redirect_to @document.to_iframe
#      #@document = Document.find(@service, {:id => @doc_id})
#    end
  
    def update_doc_folder
      @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
      @folder = Folder.find(@account, {:id => params[:folder]})
      @document.add_to_folder(@folder)
      redirect_to :action => 'index', :folder_id => params[:folder]
    end
    
    def new_folder
        @folder = Folder.new(@account, :title => params[:new_folder])
        if session[:folder_id]
          @folder.add_to_folder(Folder.find(@account, {:id => session[:folder_id]}))
        end
        @folder.save
        redirect_to :action => 'index', :folder_id => session[:folder_id]
    end
    
  def send_upload
    if params[:doc_id]
      doc = BaseObject.find(@account, {:id => params[:doc_id]})
      doc.content = params[:upload_file].read
      doc.content_type = File.extname(params[:upload_file].original_filename).gsub(".", "")
      if doc.save
        flash[:notice] = 'File successfully uploaded'
      else
        flash[:warning] = 'Could not upload file!'
      end
      redirect_to :action => :view, :doc_id => doc.id and return
    else
      file = BaseObject.new(@account)
      file.title = params[:upload_file].original_filename.gsub(/\.\w.*/, "")
      file.content = params[:upload_file].read
      file.content_type = File.extname(params[:upload_file].original_filename).gsub(".", "")
      if file.save
        flash[:notice] = 'File successfully uploaded'
      else
        flash[:warning] = 'Could not upload file!'
      end
      if session[:folder_id]
        file.add_to_folder(Folder.find(@account, {:id => session[:folder_id]}))
      end 
      
      redirect_to :action => :index, :folder_id => session[:folder_id] and return
    end
  end

  def delete
    obj = nil
    if params[:doc_id]
      obj = BaseObject.find(@account, {:id => params[:doc_id]})
    elsif params[:folder_id]
      obj = Folder.find(@account, {:id => params[:folder_id]})
    end
    if obj and obj.delete
      flash[:notice] = 'Successfully deleted!'
    else
      flash[:notice] = "Error deleting!"
    end
    redirect_to request.referer
  end
  
  def add_user
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    @document.add_access_rule(params[:user], params[:role])
    redirect_to :action => :view, :doc_id => @document.id, :id => '1'
  end
  
  def update_user
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    @document.update_access_rule(params[:user], params[:role])
    redirect_to :action => :view, :doc_id => @document.id, :id => '1'
  end
  
  def remove_user
    @document = BaseObject.find(@account, {:id => CGI::unescape(params[:doc_id])})
    @document.remove_access_rule(params[:user])
    redirect_to :action => :view, :doc_id => @document.id, :id =>'1'
  end

 
end