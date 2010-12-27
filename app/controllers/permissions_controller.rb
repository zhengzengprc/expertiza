class PermissionsController < ApplicationController
require 'aquarium'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @permissions = Permission.paginate(:page => params[:page],:per_page => 10)
  end

  def show
    @permission = Permission.find(params[:id])
    @pages = ContentPage.find_for_permission(params[:id])
    @actions = ControllerAction.find_for_permission(params[:id])
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(params[:permission])
    if @permission.save
      flash[:notice] = 'Permission was successfully created.'
      Role.rebuild_cache
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @permission = Permission.find(params[:id])
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update_attributes(params[:permission])
      flash[:notice] = 'Permission was successfully updated.'
      Role.rebuild_cache
      redirect_to :action => 'show', :id => @permission
    else
      render :action => 'edit'
    end
  end

  def destroy
    Permission.find(params[:id]).destroy
    Role.rebuild_cache
    redirect_to :action => 'list'
  end
  
  
include Aquarium::DSL
  around :methods => [:index, :list, :show, :new, :create, :edit, :update, :destroy] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
