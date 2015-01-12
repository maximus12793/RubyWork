# -*- encoding : utf-8 -*-
class ProjectsController < ApplicationController
  before_filter :require_login

  def secure_remove

    logger.debug params
    authorize! :manage, @project
    @project   = Project.find(params[:id_p])#es el que quiero borrar
    @project_p = Project.find(params[:project_p])#sera el nuevo

    @project.purchase_requisitions.each do |pr| 
        pr.project_id = @project_p.id;
        pr.save
    end

    @project.destroy

    respond_to do |format|
        #format.html { redirect_to items_url }
        format.json { render json: @item_p }
    end

  end

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
    perpage= params[:perpage] || 10
    @project_grid = initialize_grid(Project,:order_direction => 'asc',:per_page => perpage)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

    @pr_project_grid = initialize_grid(PurchaseRequisition.where(:project_id => @project.id),:include => [:creator,:project] ,:order =>'purchase_requisitions.requested_date',:order_direction => 'asc',:per_page => 10)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
      @project = Project.new(params[:project])
      authorize! :manage, @project

      respond_to do |format|
          if @project.save
              format.html { redirect_to projects_path, notice: 'Proyecto fue creado exitosamente.' }
              format.json { render json: @project, status: :created, location: @project }
          else
              format.html { render action: "new" }
              format.json { render json: @project.errors, status: :unprocessable_entity }
          end
      end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update

    @project = Project.find(params[:id])
    authorize! :manage, @project

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Proyecto fue actualizado.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy

    @project = Project.find(params[:id])
    authorize! :manage, @project

    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end

  end

end
