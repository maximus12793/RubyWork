# -*- encoding : utf-8 -*-
class PurchaseRequisitionsController < ApplicationController

  before_filter :require_login
  helper_method :calculate_status
  helper :all

  helper_method :sort_column, :sort_direction, :responsibles

  include ApplicationHelper

  #has_scope :by_id

  # GET /purchase_requisitions
  # GET /purchase_requisitions.json

  def history
      @purchase_requisition = PurchaseRequisition.find(params[:id])

      
      @audits=Kaminari.paginate_array(@purchase_requisition.audits.sort_by{|e| -e.id}).page(params[:page]).per(10)

      respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @purchase_requisitions }
      end  

  end 

  def reload_div
    respond_to do |format|
      format.js
    end
  end

  def index2
    @purchase_requisitions = PurchaseRequisition.all
    @pr_grid = initialize_grid(PurchaseRequisition,:include => :creator ,:order =>'purchase_requisitions.requested_date',:order_direction => 'asc',:per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_requisitions }
    end
  
  end  

  def index

    @purchase_requisitions = params[:keyWord] && params[:keyWord] !="" ? PurchaseRequisition.search(params[:keyWord]) : PurchaseRequisition

    perpage= params[:perpage] || 10
    @pr_grid = initialize_grid(@purchase_requisitions,:include => [:creator,:projects] ,:order =>'purchase_requisitions.id',:order_direction => 'desc',:per_page => perpage)
    @no_display = params[:grid] == nil
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_requisitions }
    end

  end

  # GET /purchase_requisitions/1
  # GET /purchase_requisitions/1.json
  def show
    @purchase_requisition = PurchaseRequisition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase_requisition }
    end
  end

  # GET /purchase_requisitions/new
  # GET /purchase_requisitions/new.json
  def new
    @purchase_requisition = PurchaseRequisition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @purchase_requisition }
    end
  end

  # GET /purchase_requisitions/1/edit
  def edit
    @purchase_requisition = PurchaseRequisition.find(params[:id])
  end

  # POST /purchase_requisitions
  # POST /purchase_requisitions.json
  def create
    @purchase_requisition = PurchaseRequisition.new(params[:purchase_requisition])

    if ( !@purchase_requisition.filled_form_date)
       @purchase_requisition.filled_form_date = Time.now
       #logger.info "LA hora es:" + Time.now.to_s
    end

    if ( !@purchase_requisition.creator )
       @purchase_requisition.creator = current_user

        #logger.info "HEEEYYYY*************************"
        #logger.info @purchase_requisition.requisition_entries
    end

    respond_to do |format|
      
      if @purchase_requisition.save
         @purchase_requisition.folio = @purchase_requisition.id;
        @purchase_requisition.save

#        @purchase_requisition.calculate_status 
        
        destinatarios = params[:destinatarios] || []      
        destinatarios << User.where(username:"Compradores")[0] # Es el usuario por default
        destinatarios << @purchase_requisition.buyer_id if @purchase_requisition.buyer_id#imgina Gerente Suministros quieres CREAR una SC y asignar Comprador (este codigo solo corre cuando creas ys olo el jefe de compras asigna comprador) 

#DEPARTMENTS  = ['---','Dirección', 'Ventas','Ingeniería','Sistemas','Gerencia Planta','Suministros','Proyectos','Logística','Admin./Finanzas','Recursos humanos','Materiales','Calidad','Mantenimiento','Producción','Seguridad']# el ultimo es el 11 empieza en 0
#                    0       1*         2*        3*          4*               5*             6*              7*         8*             9*               10*         11*          12*       13*             14*           15


        if @purchase_requisition.department == 5  ||#Gerencia Planta
           @purchase_requisition.department == 11 ||#Materiales
           @purchase_requisition.department == 12 ||#Calidad 12
           @purchase_requisition.department == 13 ||#Mantenimiento 13
           @purchase_requisition.department == 14   #Producción 14
            User.where(title: 8).each do |user|
              destinatarios << user
            end
        end

        if @purchase_requisition.department == 6 #Suministros
            User.where(title: 9).each do |user|
              destinatarios << user
            end
        end
        if @purchase_requisition.department == 7 #Proyectos
            User.where(title: 10).each do |user|
              destinatarios << user
            end
        end

        if @purchase_requisition.department == 15 #Seguridad
            User.where(title: 11).each do |user|
              destinatarios << user
            end
        end


        if destinatarios.count > 0 
           mail = UserMailer.new_obj_email( current_user, destinatarios, @purchase_requisition )
           send_email(mail, destinatarios)
        end

        @purchase_requisition.requisition_entries.each do |re|
            if re.responsible
              mail = UserMailer.assigned_entry_or_service(current_user,re)# por default lo manda a los responsables
              send_email(mail, [re.responsible_id],"notify" + re.responsible_id.to_s,"Responsable Notificado:" )

            end
        end
=begin
        @purchase_requisition.services.each do |ser|
            if ser.responsible

              mail = UserMailer.assigned_entry_or_service(current_user,ser) # por default lo manda a los responsables
              send_email(mail, [re.responsible_id],"notify" + re.responsible_id.to_s,"Responsable Notificado:" )

            end
        end
=end

        format.html { redirect_to @purchase_requisition, notice: 'Solicitud de compra generada.' }
        format.json { render json: @purchase_requisition, status: :created, location: @purchase_requisition }
      else
        format.html { render action: "new" }
        format.json { render json: @purchase_requisition.errors, status: :unprocessable_entity }
      end
    end
  end

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


 #helper_method :addEntry

  # PUT /purchase_requisitions/1
  # PUT /purchase_requisitions/1.json
  def update
      
      @purchase_requisition = PurchaseRequisition.find(params[:id])
      @cu                   = current_user
      #puts "+++++++++++REEOLD" + @purchase_requisition.re_materials.count.to_s + "**********************"
       rem = []

      respond_to do |format|
          
          if ( @purchase_requisition.update_attributes(params[:purchase_requisition]) )
          
           # @purchase_requisition.calculate_status  NO CALCULES ESTATUS HASTAQ EU NO SEPAMOS BIEN Q ONDA!!

            #-------------------Esta parte es un poco rara pero enserio funciona para ver cuales eliminaron---------------------
            @purchase_requisition.re_materials.each do |reM|
                rem << reM if ! ReMaterial.exists?(reM.id)
            end

            @purchase_requisition.re_services.each do |reS|
              rem << reS if ! ReService.exists?(reS.id)
            end

            #-------------------Fin de la parte que  es un poco rara pero enserio funciona para ver cuales eliminaron---------------------

            #-------------------Correos por default y los involucrados---------------------
            
            destinatarios = params[:destinatarios] || []
            destinatarios << User.where(username:"Compradores")[0]
            destinatarios << @purchase_requisition.creator_id if @purchase_requisition.creator_id

            if @purchase_requisition.buyer
              destinatarios << @purchase_requisition.buyer_id
            end

            if destinatarios.count >0 && (@purchase_requisition.has_changed? || rem.count > 0 )
              
              mail = UserMailer.update_email(current_user,destinatarios,@purchase_requisition,rem)
              send_email(mail, destinatarios)

            end

            #-------------------- FIN Correos por default y los involucrados FIN------------------

            #-------------------Correo para Responsables---------------------

            re_resp  = @purchase_requisition.re_changed_resp
            mail_responsibles = re_resp

            if mail_responsibles.count >0 && (@purchase_requisition.has_changed? || rem.count > 0 )
                #implica que hubo un cambio
                mail = UserMailer.update_email(current_user,mail_responsibles,@purchase_requisition,rem)
                send_email(mail, mail_responsibles,:notice_mail2,"Correo electrónico enviado a responsables: <br />" )

            end

            #------------------- FIN  Correo para Responsables---------------------     

            notice_mail = @purchase_requisition.has_changed? || rem.count > 0 ?  'Solicitud de Compra Actualizada.' : "No hubo cambios."

            #puts "+++++++++++" + @purchase_requisition.requisition_entries.count.to_s + "**********************"

            format.html { redirect_to @purchase_requisition,  notice: notice_mail }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @purchase_requisition.errors, status: :unprocessable_entity }
          end

      end
  end

  # DELETE /purchase_requisitions/1
  # DELETE /purchase_requisitions/1.json
  def destroy
      @purchase_requisition = PurchaseRequisition.find(params[:id])
      id = 0
      if @purchase_requisition.destroyable?

        destinatarios = []

        destinatarios << @purchase_requisition.creator_id if @purchase_requisition.creator
        destinatarios << @purchase_requisition.buyer_id if @purchase_requisition.buyer

        @purchase_requisition.requisition_entries.each do |re|
            destinatarios << re.responsible_id if re.responsible
        end

        mail = UserMailer.pr_delete_email( current_user,destinatarios ,@purchase_requisition )
        send_email(mail, destinatarios)

        @purchase_requisition.requisition_entries.each do |re|
           re.delete
        end
        id = @purchase_requisition.id
        @purchase_requisition.destroy
      else
        #@purchase_requisition.errors[:base] << "This person is invalid because ..."
        redirect_to(purchase_requisitions_url, :alert => 'Imposible eliminar SC debido a los estatus de las partidas.')
        return
      end

      respond_to do |format|
        format.html { redirect_to purchase_requisitions_url, :alert => "SC # " + id.to_s +  " eliminada.".html_safe }
        format.json { head :no_content }
      end
  end

  def assign_requisition
      redirect_to purchase_requisitions_url
  end



  def correct_query

        if ( PurchaseRequisition.column_names.include?(params[:sort]) )
          logger.debug" AQUI ESTAS MAL"
            return  PurchaseRequisition.order(params[:sort] + " " + sort_direction ) 
        else  
           if( User.column_names.include?(params[:sort]) )
                logger.debug " AQUI ESTaS BIEN"
            
               return PurchaseRequisition.joins(:creator).order(params[:sort]+ " " + sort_direction)
           end
        end

    return PurchaseRequisition.order(sort_column+ " " + sort_direction )
      
  end

    def add_new_comment

      pr     = PurchaseRequisition.find(params[:id])
      coment = Comment.new(params[:comment])
      pr.comments << coment

      destinatarios = params[:destinatarios] || []
      destinatarios << User.where(username:"Compradores")[0] 

      destinatarios << pr.buyer_id  if (pr && pr.buyer_id)
      destinatarios << pr.creator_id if (pr && pr.creator_id )

      if destinatarios.count > 0
         mail = UserMailer.new_comment(current_user,destinatarios,coment,pr)
         send_email(mail, destinatarios)
      end

      redirect_to :action => :edit, :id => pr
    end

    def delete_comment 
      @comment= Comment.find(params[:id])
      @comment.delete
      redirect_to :back

    end
    
    def remind_aprobation

        @purchase_requisition = PurchaseRequisition.find(params[:id])

        destinatarios = []

        if @purchase_requisition.department == 5  ||#Gerencia Planta
             @purchase_requisition.department == 11 ||#Materiales
             @purchase_requisition.department == 12 ||#Calidad 12
             @purchase_requisition.department == 13 ||#Mantenimiento 13
             @purchase_requisition.department == 14   #Producción 14
              User.where(title: 8).each do |user|
                destinatarios << user
              end
        end

        

        mail = UserMailer.pr_aprove_it(current_user,destinatarios,@purchase_requisition)
        send_email(mail, destinatarios)

        respond_to do |format|
          format.json { render json: {"result" =>1 }.to_json}
        end



    end

    private

    def responsibles(pr)

         pr.services.each do |s|
            if s.resposible_id

              responsibles << s.resposible_id

             end

         end

         pr.requisition_entries.each do |re|
             if re.resposible_id
               responsibles << re
             end
         end

         return responsibles
    end

end
