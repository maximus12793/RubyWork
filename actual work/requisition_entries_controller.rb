# -*- encoding : utf-8 -*-
class RequisitionEntriesController < ApplicationController
  before_filter :require_login
  # GET /requisition_entries
  # GET /requisition_entries.json

  helper_method :sort_column, :sort_direction

  include ApplicationHelper

  def history

      @requisition_entry = RequisitionEntry.find(params[:id])
      @audits = Kaminari.paginate_array(@requisition_entry.audits.sort_by{|e| -e.id}).page(params[:page]).per(10)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @requisition_entry }
      end

  end

  def delete_comment 

      @comment = Comment.find(params[:id])
      @comment.delete
      redirect_to :back
      
  end

  def add_new_comment

      re      = RequisitionEntry.find(params[:id])
      comment = Comment.new(params[:comment])
      re.comments << comment

      destinatarios = params[:destinatarios] || []
      destinatarios << User.where(username:"Compradores")[0] 
      destinatarios << re.purchase_requisition.creator_id if(re.purchase_requisition && re.purchase_requisition.creator_id)

      destinatarios.concat(re.responsible_and_buyer)

      if destinatarios.count > 0
          mail = UserMailer.new_comment(current_user,destinatarios,comment,re)
          send_email(mail,destinatarios)

      end

      

      redirect_to :back

  end

  def index

     #@requisition_entries = params[:keyWord] && params[:keyWord] !="" ? RequisitionEntry.search(params[:keyWord],params[:expired]) : RequisitionEntry

     @title=""
     #@requisition_entries = RequisitionEntry.specialSearch(params[:keyWord],params[:expired])
     if(params[:type] == "activas")
        @requisition_entries = RequisitionEntry.specialSearchINCompleted(params[:keyWord],params[:expired])
        @title ="(activas)"
     elsif (params[:type] == "recibidas")
        @requisition_entries = RequisitionEntry.specialSearchCompleted(params[:keyWord],params[:expired])
        @title ="(recibidas)"
     else
        @requisition_entries = RequisitionEntry.specialSearch(params[:keyWord],params[:expired])
        @title ="(todas)"
     end

      perpage= params[:perpage] || 10
      RequisitionEntry.set_expireds # activa las banderas de los registros que ya expiraron

      #perpage= params[:perpage] || 10
      @re_grid = initialize_grid( @requisition_entries, :include => [:purchase_requisition,:unit,:service ],:per_page => perpage )

      @no_display = params[:grid] == nil
    
      respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @requisition_entries }
      end
  end


  # GET /requisition_entries/1
  # GET /requisition_entries/1.json
  def show
      @requisition_entry = RequisitionEntry.find(params[:id])
      @requisition_entry.set_expired

      respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @requisition_entry }
      end
  end

  # GET /requisition_entries/new
  # GET /requisition_entries/new.json
  def new

      @requisition_entry = RequisitionEntry.new
      @requisition_entry.item = Item.new 

      respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @requisition_entry }
      end

  end

  # GET /requisition_entries/1/edit
  def edit
    @real_object       = RequisitionEntry.find(params[:id])
    @requisition_entry = RequisitionEntry.find(params[:id])#.becomes(RequisitionEntry)#Hago el become para que pueda generar la forma!
    @requisition_entry.set_expired
  end

  # POST /requisition_entries
  # POST /requisition_entries.json
  def create

      @requisition_entry = RequisitionEntry.new(params[:requisition_entry])

      if ( ! @requisition_entry.status)
         @requisition_entry.status = STATUSES[0]
      end

      respond_to do |format|
          if @requisition_entry.save
              format.html { redirect_to @requisition_entry, notice: 'Solicitud de compra creada exitosamente.' }
              format.json { render json: @requisition_entry, status: :created, location: @requisition_entry }
          else
              format.html { render action: "new" }
              format.json { render json: @requisition_entry.errors, status: :unprocessable_entity }
          end
      end
  end

  # PUT /requisition_entries/1
  # PUT /requisition_entries/1.json
  def update
      
      @requisition_entry = RequisitionEntry.find(params[:id])
      
      respond_to do |format|

          if @requisition_entry.update_attributes(params[:requisition_entry])
            
            @requisition_entry.set_expired

            #-------------------Correos por default y los involucrados---------------------
            destinatarios = params[:destinatarios] || []
            destinatarios << User.where(username:"Compradores")[0] 
            destinatarios << @requisition_entry.purchase_requisition.creator_id if @requisition_entry.purchase_requisition

#            default = User.find_by_username("Departamento Compras")
#            default_id =  default ? default.id : nil

            destinatarios.concat(@requisition_entry.responsible_and_buyer) if @requisition_entry.has_changed?


            if destinatarios.count > 0 && @requisition_entry.has_changed?

                mail = UserMailer.update_email(current_user,destinatarios,@requisition_entry)  
                send_email(mail,destinatarios)

            elsif @requisition_entry.has_changed?
                 notice_email = "Cambios registrados y no se envió correo electrónico."
            else
                 notice_email = "No hubo cambios y no se envió correo electrónico."
            end

            #-------------------- FIN Correos por default y los involucrados FIN------------------

            format.html { redirect_to requisition_entry_path(params[:id]), notice: notice_email }
            format.json { head :no_content }
          else
            @real_object   = @requisition_entry #lo necesito por en caso de que falle al guardar el objeto y vuelva a renderear el Edit
            format.html { render action: "edit" }
            format.json { render json: @requisition_entry.errors, status: :unprocessable_entity }
          end
      end

  end

  # DELETE /requisition_entries/1
  # DELETE /requisition_entries/1.json
  def destroy
    @requisition_entry = RequisitionEntry.find(params[:id])
    @requisition_entry.destroy
    respond_to do |format|
      format.html { redirect_to requisition_entries_url }
      format.json { head :no_content }
    end
  end

  private 

  def sort_column

      if(RequisitionEntry.column_names.include?(params[:sort]))  
        return params[:sort]
      end
      if( Item.column_names.include?(params[:sort]) )
        return params[:sort]
      end
      if( PurchaseRequisition.column_names.include?(params[:sort]) )
        return params[:sort]
      end
      "id"
  end


  def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"  
  end


  def correct_query

        if ( RequisitionEntry.column_names.include?(params[:sort]) )
              RequisitionEntry.order(params[:sort] + " " + sort_direction ) 
        else  
          
             if( Item.column_names.include?(params[:sort]) )
              
                 return RequisitionEntry.joins(:item).order(params[:sort]+ " " + sort_direction)
             end

             if( PurchaseRequisition.column_names.include?(params[:sort]) )
              
                 return RequisitionEntry.joins(:purchase_requisition).order(params[:sort]+ " " + sort_direction)
             end

             if( Supplier.column_names.include?(params[:sort]) )
              
                 return RequisitionEntry.joins(:supplier).order(params[:sort]+ " " + sort_direction)
             end

             if( User.column_names.include?(params[:sort]) )
              
                 return RequisitionEntry.joins(:reciver).order(params[:sort]+ " " + sort_direction)
             end


        end
        return RequisitionEntry.order(sort_column+ " " + sort_direction )
  end

end
