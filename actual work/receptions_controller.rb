# -*- encoding : utf-8 -*-
class ReceptionsController < ApplicationController
	include ApplicationHelper
	include ActionView::Helpers::TagHelper

	def new
		@reception = Reception.new
	end

	def show
		@reception = Reception.find(params[:id])
	end

	def edit
	  	@reception = Reception.find(params[:id])
	end

	def update
		@reception = Reception.find(params[:id])

		respond_to do |format|
			    if @reception.update_attributes(params[:reception])


	    	          #-------------------Correos por default y los involucrados---------------------
	    	           destinatarios = params[:destinatarios] || []
	    	           destinatarios << User.where(username:"Compradores")[0] 

	    	           destinatarios.concat(@reception.requisition_entry.responsible_and_buyer) if @reception.has_changed?

	    	           if destinatarios.count > 0 && @reception.has_changed?

	    	                mail = UserMailer.update_email(current_user,destinatarios,@reception)  
	    	                send_email(mail,destinatarios)

	    	           elsif @reception.has_changed?
	    	                 notice_email = "Cambios registrados y no se envió correo electrónico."
	    	           else
	    	                 notice_email = "No hubo cambios y no se envió correo electrónico."
	    	           end

	    	            #-------------------- FIN Correos por default y los involucrados FIN------------------
				      format.html { redirect_to reception_path(@reception), notice: notice_email }
				      format.json { head :no_content }
			    else
				      format.html { render action: "edit" }
				      format.json { render json: @reception.errors, status: :unprocessable_entity }
			    end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.json
	def destroy
		  @reception = Reception.find(params[:id])
		  @reception.destroy

		  respond_to do |format|
			    format.html { redirect_to :back }
			    format.json { head :no_content }
		  end
	end

	def index
		perpage= params[:perpage] || 10
		@receptions =Reception.all
		@rec_grid = initialize_grid(Reception,:include =>[:requisition_entry,:supplier,:reciver],:per_page => perpage)
	end

	def reception_registration_form

		re_id_hash   =  Hash.try_convert("requisition_entry_id"=>params["requisition_entry_id"])
		re_date_hash =  Hash.try_convert("recived_date"=>Date.today())
		mr_hash 	 =  params["reception"]

		mr_hash = mr_hash.merge(re_id_hash)
		mr_hash = mr_hash.merge(re_date_hash)

		@reception = Reception.new(mr_hash)

		logger.fatal params



		#Le voy a asignar el valor al requisition_entry de su status
			if  RequisitionEntry.exists?(params["requisition_entry_id"]) 

				re = RequisitionEntry.find(params["requisition_entry_id"]) 
				re.status = params["status"]; 

				if( re.status < 5 )
					#errors.add(:estatus_invalido, "Estatus debe ser superior a 'Recibido Parcial' ")
					redirect_to :back, alert:  print_as_error("Estatus NO válido.").html_safe 
					return
				else
					re.save
				end
			end
		#Ya le asigné el valor al status del requisition_entry.


		if @reception.save 
		  
		  if @reception.requisition_entry

			  destinatarios = []
			  destinatarios << User.where(username:"Compradores")[0] 
			  destinatarios.concat(@reception.requisition_entry.responsible_and_buyer)
			  
			  if destinatarios.count > 0
			        mail = UserMailer.recive_email(current_user,destinatarios,@reception.requisition_entry.audits.last,@reception) 
			        send_email(mail, destinatarios)
			  end

		  end
		  #Fin de envio de Email
		  redirect_to :back, notice: 'Recepción registrada.'

		else
		  redirect_to :back, alert:  print_error(@reception.errors).html_safe 
		end
	end

	def add_new_comment

	  mr = Reception.find(params[:id])
	  coment=Comment.new(params[:comment])
	  mr.comments << coment

	  destinatarios = params[:destinatarios] || []
	  destinatarios << User.where(username:"Compradores")[0] 

	  destinatarios.concat(mr.requisition_entry.responsible_and_buyer) if mr.requisition_entry 

	  if destinatarios.count > 0
	      mail = UserMailer.new_comment(current_user,destinatarios,coment,mr)
	      send_email(mail, destinatarios)
	  end

	  redirect_to :back 
	end

	def delete_comment 
	  @comment= Comment.find(params[:id])
	  @comment.delete
	  redirect_to :back

	end

	def history

	  @material_reception = Reception.find(params[:id])
	  @audits  			  = @material_reception.audits.page(params[:page]).per(10)

	  respond_to do |format|
		    format.html 
		    format.json { render json: @service }
	  end

	end


end
