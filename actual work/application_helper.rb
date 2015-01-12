# -*- encoding : utf-8 -*-
module ApplicationHelper


	def span2row(text, value, trn = nil)
		content_tag( :div, class: "control-group row-fluid ") do
			if (value && trn)
				value = truncate(value, length: trn)
			end 
			content_tag(:div, content_tag(:b, text) ,class: "span2 offset5") +
			content_tag(:div, (value ? value : "---"), class: "span1 ")
		end
	end

	def span2p2row(text, value,text2 = nil,value2 = nil, trn = nil)

		content_tag( :div, class: "control-group row-fluid ") do

			if (value && trn)# trunca si es necesario
				value = truncate(value, length: trn)
			end 

			if text2 == nil  && value2 == nil #caso de que sea solo un valor a imprimir
				content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value)) ,class: "span2 offset4")
			end

			content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value)) ,class: "span2 offset4 well") +
			content_tag(:div, content_tag(:b, p_null(text2,false,""))+ content_tag(:br, p_null(value2,false,"")),class: "span2 well") 
			
		end
	end

	def span3p2row(text, value,text2 = nil,value2 = nil, trn = nil)

		content_tag( :div, class: "control-group row-fluid ") do

			if (value && trn)# trunca si es necesario
				value = truncate(value, length: trn)
			end 

			if text2 == nil  && value2 == nil #caso de que sea solo un valor a imprimir
				content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value)) ,class: "span3 offset3")
			end

			content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value)) ,class: "span3 offset3 well") +
			content_tag(:div, content_tag(:b, p_null(text2,false,""))+ content_tag(:br, p_null(value2,false,"")),class: "span3 well") 
			
		end
	end

	def span2p3row(text, value,text2 = nil,value2 = nil,text3=nil,value3=nil, trn = nil)
		content_tag( :div, class: "control-group row-fluid ") do

			if (value && trn)# trunca si es necesario
				value = truncate(value, length: trn)
			end 
			if (value2 && trn)# trunca si es necesario
				value2 = truncate(value3, length: trn)
			end
			if (value3 && trn)# trunca si es necesario
				value3 = truncate(value3, length: trn)
			end
			

			content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value)) ,class: "span2 offset3 well") +
			content_tag(:div, content_tag(:b, p_null(text2,false,""))+ content_tag(:br, p_null(value2,false,"")),class: "span2 well") +
			content_tag(:div, content_tag(:b, p_null(text3,false,""))+ content_tag(:br, p_null(value3,false,"")),class: "span2 well") 
			
		end

	end

	def span3p3row(text, value,text2 = nil,value2 = nil,text3=nil,value3=nil, trn = nil)
		content_tag( :div, class: "control-group row-fluid ") do

			if (value && trn)# trunca si es necesario
				value = truncate(value, length: trn)
			end 
			if (value2 && trn)# trunca si es necesario
				value2 = truncate(value3, length: trn)
			end
			if (value3 && trn)# trunca si es necesario
				value3 = truncate(value3, length: trn)
			end
			

			content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:b, p_null(value),class: "color: rgb(255, 255, 255) "),class: "span3 offset2 well") +
			content_tag(:div, content_tag(:b, p_null(text2,false,""))+ content_tag(:br, p_null(value2,false,"")),class: "span3 well") +
			content_tag(:div, content_tag(:b, p_null(text3,false,""))+ content_tag(:br, p_null(value3,false,"")),class: "span3 well") 
			
		end

	end


	def span2p4row(text, value,text2 = nil,value2 = nil,text3=nil,value3=nil,text4=nil,value4=nil,trn = nil)
		content_tag( :div, class: "control-group row-fluid ") do

			if (value && trn)# trunca si es necesario
				value = truncate(value, length: trn)
			end 
			if (value2 && trn)# trunca si es necesario
				value2 = truncate(value3, length: trn)
			end
			if (value3 && trn)# trunca si es necesario
				value3 = truncate(value3, length: trn)
			end
			if (value4 && trn)# trunca si es necesario
				value4 = truncate(value4, length: trn)
			end
			

			content_tag(:div, content_tag(:b, p_null(text)) + content_tag(:br, p_null(value),) ,class: "span2 offset2 well") +
			content_tag(:div, content_tag(:b, p_null(text2,false,""))+ content_tag(:br, p_null(value2,false,"")),class: "span2 well") +
			content_tag(:div, content_tag(:b, p_null(text3,false,""))+ content_tag(:br, p_null(value3,false,"")),class: "span2 well") +
			content_tag(:div, content_tag(:b, p_null(text4,false,""))+ content_tag(:br, p_null(value4,false,"")),class: "span2 well")
		end

	end

	def table2pN(hash)

		rows=""

		hash.each do |pair|
			td1 = content_tag(:td,content_tag( :b,pair[0].to_s )  )
			td2 = content_tag(:td,pair[1].to_s   )
			td1mtd2 = td1.concat(td2)
			rows.concat(content_tag :tr, td1mtd2)

		end
		content_tag :table, rows.html_safe
	end



	def p_att(obj,att, default= nil)

		st = obj ? (obj[att] ? obj[att] : "---"  ) : "---"

		if default &&  (st == "---" )
			st= default
		end

		return st

	end

	def p_assets(obj,rem = false)

		res =  obj && obj.count > 0 ?  obj : "---"

		if res.class == Array 
			res = ""

			obj.each do |asset|

				inner = link_to( p_null(asset.avatar_file_name,15), asset.avatar.url ).html_safe

				if rem
					tag = content_tag(:i, nil, :class => "icon-trash" )
					inner +=  link_to(tag, asset, :method => :delete, :confirm => "¿Estás seguro?").html_safe
				end
				
				res += content_tag( :li, inner ).html_safe
				

			end

			res = content_tag(:ul,res.html_safe).html_safe 

		end

		return res.html_safe;

	end

	def p_documents_index(arr_doc)

		str = nil

		if arr_doc == nil 
			str = "---" 
		end	

		str = "---" if arr_doc.blank?

		if str == nil && arr_doc.class.to_s == String.to_s
			arr_doc=arr_doc.split(",").map{|s| s.to_i}
		end

	   if str == nil
			str = ""

			arr_doc.each do |doc|
				if (doc!=0)
					str = str + content_tag(:p , Document.find(doc).name).html_safe
				else
					str = str+":::" 
				end
			end

		end

		return str.html_safe

	end


	def p_documents(arr_doc)

		str = nil

		if arr_doc == nil 
			str = "---" 
		end	

		str = "---" if arr_doc.blank?


		if str == nil
			str = ""

			arr_doc.each do |doc|
				str = str + content_tag(:p , doc.name).html_safe
			end

		end


		return str.html_safe


	end

	def p_bool(obj)

		obj ? "Si" : "No"

	end

	def p_method(obj,method,default = nil)

		default = default || "---"

		if obj

			r = obj.send(method) 
			r ? r : default 

		else
			default
		end 
			
	end

	def link_to_remove_fields(name,f,options = {})
		tag = content_tag(:i, nil, :class => "icon-remove" )
		f.hidden_field(:_destroy) + link_to_function(tag,"remove_fields(this)",options)
	end

	def link_to_copy_fields(name,f,options = {})
		tag = content_tag(:i, nil, :class => "icon-hand-down" )
		link_to_function(tag,"copyRow(this);",options)
	end



	def  link_to_remove(obj)

		tag = content_tag(:i, nil, :class => "icon-remove" )
		content_tag :a, tag, class:"remove"+obj.class.to_s, name: obj.id

	end


	def link_to_add_fields(name,f,association,options={},service_flag)
		new_object = f.object.class.reflect_on_association(association).klass.new

		Rails.logger.info "LINK TO ADDDD FIELDDSSS****!!!!!!"
		Rails.logger.info new_object.inspect

		fields = f.fields_for( association,new_object,:child_index=>"new_#{ association }" ) do |builder|
		#fields = f.fields_for( association,new_object,:child_index=>"new_#{ association }" ) do |builder|
					render(association.to_s.singularize + "_fields", :f=>builder, :service_flag=>service_flag )
					#render( "requisition_entry_fields", :f=>builder, :service_flag=>service_flag, :service_flag=>service_flag )
				  end

		link_to_function(name,"add_fields(this, \"#{association}\", \"#{escape_javascript(fields) }\" )",options)
		#link_to_function(name ,"add_fields(this, \"new_requisition_entry\", \"#{escape_javascript(fields) }\" )",options)
		
	end

		def link_to_add_fieldsRE(name,f,association,options={},service_flag)
		new_object = f.object.class.reflect_on_association(association).klass.new
		#new_object  = RequisitionEntry.new 
		#Rails.logger.info "LINK TO ADDDD FIELDDSSS****!!!!!!"
		#Rails.logger.info new_object.inspect
		
		fields = f.fields_for(:requisition_entries, new_object.becomes(RequisitionEntry),:child_index=>"new_requisition_entry" ) do |builder|
					
					render( "requisition_entry_fields", :f=>builder, :service_flag=>service_flag )
				  end

		
		link_to_function(name ,"add_fields(this, \"new_requisition_entry\", \"#{escape_javascript(fields) }\" )",options)
		
	end

	def link_to_add_files(association,f,options={})
		
		fields = f.fields_for(association ,Asset.new ) do |builder|

					builder.file_field :avatar
					
				  end

		tag=content_tag(:i, nil, :class => "icon-plus" )

		link_to_function(tag + "Archivo","addFileEntry(this, \"#{association}\", \"#{escape_javascript(fields) }\" )",options)
		
	end

	def link_to_show(path,options = {})

		tag = content_tag(:i, nil, :class => "icon-search",title:"Mostrar" )
		
	    link_to(tag,path,options)
	end

	def link_to_edit(path,options = {})

		tag = content_tag(:i, nil, :class => "icon-pencil",title:"Editar" )
		
	    link_to(tag,path,options)
	end

	def link_to_destroy(path)
		tag = content_tag(:i, nil, :class => "icon-remove ",title:"Eliminar"   )
		link_to(tag,path,method: :delete,confirm:"¿Estás seguro que deseas eliminarlo?")
		
	end

	def link_to_recive(obj,unit_s)

		tag = content_tag(:i, nil, :class => "icon-ok",title:"Registrar recepción"  )
		

		link_to_function(tag, "recive(this,#{obj},'" + unit_s + "')")

	end

	def p_null(txt,trn = false,alt="----")

		if txt
			txt.blank? ? "  ---- " : (trn ? truncate(txt, length:trn) : txt.to_s )
		else
			alt
		end
	end

	def p_sts (index)

		if index.class == String 
			index = index.to_i >= 0 ? index.to_i : "---"
		end

		if index.class == Fixnum && index < STATUSES.count && index >= 0
			STATUSES[index] 
		else
			index
		end
	end

	def p_department (index)

		if index.class == String && index != "0"
			index = index.to_i > 0 ? index.to_i : "---"
		elsif index == "0"
			index = index.to_i
		end


		if index.class == Fixnum && index < DEPARTMENTS.count && index >= 0
			DEPARTMENTS[index] 
		else
			index
		end
	end

	def p_service(index)

		if index.class==String
			index= index.to_i>=0 ? index.to_i : "---"
		end 

		if index.class == Service
			index=index.id
		end

		Service.exists?(index) ? p_null(Service.find(index).name) : "---"

	end



	def p_pr_sts (index)

		if index.class == String && index != "0"
			index = index.to_i > 0 ? index.to_i : "---"
		elsif index =="0"
			index = index.to_i
		end


		if index.class == Fixnum && index < STATUSES.count && index >= 0
			PR_STATUSES[index] 
		else
			index
		end
	end




	def p_title (index)

		if index.class == Fixnum && index < USER_TITLES.count && index >= 0
			USER_TITLES[index]
		else
			index
		end
	end

	def p_item (index)

		if index.class==String
			index= index.to_i>0 ? index.to_i : "---"
		end 

		if index.class ==Fixnum
			i = Item.find(index)
			i ? i.name : "NULL_ITEM"
		else
			"Sin Item"

		end

	end

	def p_supplier(index)

		if index.class==String
			index= index.to_i>=0 ? index.to_i : "---"
		end 

		
		index = index.id if index.class == Supplier
		

		if index.class == Fixnum
			
			return "---" if index == 0

			i = Supplier.find(index)
			i ? i.supplier_name : "---"
		else
			"---"
		end

	end


	def p_posible_suppliers(arr)

		return "---" if arr.count == 0
		st = ""

		arr.each do |ele|
			st += p_supplier(ele) + "<br/>" 
		end

		return raw(st)

	end


	def p_user (index)

		if index.class == String
			i=index.to_i
			index = i >= 0 ? i : "---" 
		end

		index = index.id if index.class == User

		
		return User.exists?(index) ? User.find(index).username : "---" if index.class == Fixnum
		
		return	"---"
		
	end

	def p_project (index)

		if index.class == Project
			index = index.id
		end

		if index.class == String
			i=index.to_i
			index = i > 0 ? i : "---" 
		end

		if index.class ==Fixnum
			i = Project.find(index)
			i ? i.num_name : "---"
			
		else
			"---"
		end
	end

	def p_projects (arr)
		st=""

		if arr.count == 0 
			return "---"
		end
		arr.each do |pr|
			st += p_project(pr) + "<br />"
		end

		return st.html_safe

	end



	def p_comments( text ,max_length=120 )

		if text
			
			if text.blank? 
				 "------" 
			else

				if(text.length > max_length )


					st = text.gsub("\r\n","Ç")# los enter los convierto en 'Ç'
					st = st + "Ç"

					new_st = ""

					st.split("Ç").each do |split|

						if split.length >= max_length

							original_split = split
							split = split.scan(/.{#{max_length}}/).join(" - <br /> ").html_safe#Hago los cortes necesarios
							
							last_index = original_split.length - 1
							sobrante   = last_index - (original_split.length % max_length) + 1
							
							split = split + "-Ç" + original_split[ sobrante..last_index]
						end

						new_st = new_st + split + "Ç" #le pongo el enter que tenía previamente (que le habia quitado al hacer el split)
					end

					st = new_st.gsub("Ç","<br />")#regreso los enters que había quitado

					return st.html_safe

				else
					text.html_safe
				end

			end
		 
		else
			"------"
		end

	end


	def p_units (index)

		if index.class == String
			i=index.to_i
			index = i > 0 ? i : "---" 

		end

		if index.class == Unit
			index=index.id 
		end

		if index.class == Fixnum
			 

			if Unit.exists?(index)
			  i   = Unit.find(index)
			  i.name == i.abreviation ? i.name : i.name + " (" + i.abreviation + ")"
			else 
				"---"
			end
		else
			"---"
		end
	end

	def p_arr2(arr, type=nil, br = false, linker = nil, trn =nil,max_chars = 30 )

		linker = linker ? linker : "-> <br/>" 

		if ( (arr.class == Array) && (arr.count == 2) )

			s0 = p_null arr[0] 
			s1 = p_null arr[1]  


			if type == 1 #status
				s0 = p_sts(s0).to_s
				s1 = p_sts(s1).to_s
			elsif type == 2 #supplier
				
				s0 = p_supplier(s0).to_s
				s1 = p_supplier(s1).to_s

			elsif type == 3 #unit
				s0 = p_units(s0).to_s 
				s1 = p_units(s1).to_s
			elsif type == 4 #articulo
				s0 = p_null(s0).to_s
				s1 = p_null(s1).to_s				
			elsif type == 5  #User
				s0 = p_user(s0).to_s
				s1 = p_user(s1).to_s
			elsif type == 6 || type == 9 #documents || descpription
				s0 = p_comments(s0,max_chars).to_s
				s1 = p_comments(s1,max_chars).to_s	
			elsif type == 7  #process
				s0 = p_process(s0).to_s 
				s1 = p_process(s1).to_s	
			elsif type == 8  #project
				s0 = p_project(s0).to_s 
				s1 = p_project(s1).to_s
			elsif type == 10  #department
				s0 = p_department(s0).to_s 
				s1 = p_department(s1).to_s
			elsif type == 11  #service
				s0 = p_service(s0).to_s 
				s1 = p_service(s1).to_s				
			end

			if br
				linker = linker.html_safe + "<br />".html_safe
			end	
			
			result = s0.to_s.html_safe + linker.to_s.html_safe + s1.to_s.html_safe

			trn ? truncate(result,:length => trn).html_safe : result

		else
			if type == 1
				p_sts(arr)
			elsif type ==2 

				if arr.class == String && arr.to_i >0
					arr = arr.to_i
				end

				if arr.class == Supplier
					arr = arr.id
				end

				 arr.class == Fixnum ? p_supplier(Supplier.find(arr)) : arr.to_s  
			elsif type == 7
				p_process arr
			elsif type == 3 
				p_units arr 
			elsif type == 5 
				p_user arr
			elsif type == 8 
				p_project arr
			elsif type == 9 || type == 6
				p_comments(arr, max_chars)
			elsif type == 10
				p_department(arr)
			elsif type == 11#service
				p_service(arr)
			else 
				arr
			end
		end
	end

	def trans_serv_key(key)
		 
		p_null(SERVICES_DICTIONARY[key.to_s])

	end

	def trans_re_key(key)
		 
		p_null(RE_DICTIONARY[key.to_s])

	end

	def trans_pr_key(key)
		 
		p_null(PR_DICTIONARY[key.to_s])

	end


	def p_tran_val( value,key)

		if(key == "description"||key == "observations"  )
			  value
		elsif(key == "name" )
			truncate(value,length: 30)
		elsif(key == "supplier_id")
			p_supplier(value)
		elsif (key == "buyer_id" || key == "creator_id" || key == "reciver_id" )
			p_user(value)
		elsif(key == "project_id" )
			p_project(value)
		elsif(key == "item_id" )
			p_item(value)
		elsif(key == "status" )
			p_sts(value) 
		elsif(key == "unit_id" )
			p_units( value ) 
		elsif(key == "responsible_id" )
			p_user(value) 
		elsif(key == "process" )
			p_process(value)
		elsif(key == "department" )
			p_department(value)
		else
			p_null value  
		end

	end
	
	def p_tran_class (cl)
	   CLASS_DICTIONARY.keys.index(cl.to_s) ? CLASS_DICTIONARY[cl.to_s] : cl.to_s
	end


	def same_elements?(array1, array2)
	  
	  	if array1.count == array2.count
	  		array1.to_set == array2.to_set
	  	else
	  		false
	  	end
	  	
	end

	def users_id_to_emails_string(array)

		st = ""

		array.each do |ele|

			if ele.class == User
				ele= ele.id
			end			

			if ele.class == String

				ele = ele.to_i > 0 ? ele.to_i : "---"
				ele = 0 if ele== "0"

			end

			if ele.class == Fixnum && us = User.find(ele)
				st = st + us.email + "<br />"
			end
		end
		return st.html_safe
	end

	def hash_from_array (arr)

		h= nil

		if !(arr && arr.class==Array && arr.count>0)
			return h 
		end

		h= Hash.new
		
		arr.each do |ele|
			ind=arr.index(ele);
			h[ele]=ind
		end

		return h 
	end


	def send_email(mail,destinatarios,flash_name=nil,st=nil)
		
			flash_name = flash_name || :default_notice_mail
			st 		   = st || "Correo electrónico enviado a: <br />"
			error 	   = false

		    begin
		    
	          st = st + users_id_to_emails_string(destinatarios) 
	          mail.deliver!
	          
	        rescue
	           
	            email = $!.to_s 
	            error =  true
	           
	            if email.include?("unknown user account")#este es el strign que manda el error
	               email = email.split(" ")[1]
	            end 

	            us = User.where(email: email).first
			   		           
	        ensure

	        	msg       = (st + "<br />").html_safe
				error_txt = ("El correo electrónico no fue recibido por:<br />  NO SE LE ENVIA A NINGUNO " + "<br /> #{email}").html_safe       	
	        	msg 	  = msg + error_txt.html_safe if error
	        	
				puts "antes de  msg" + msg
	        	flash[flash_name] = msg.html_safe 

	        end

	end

	def had_changed?(obj)

		if obj.audits && obj.audits.last
		    delta = Time.now - obj.audits.last.created_at
		    had_changes = delta<15 && delta>0

		    return had_changes
		end

		return false

	end
    
    def p_time(time)
    	time ? Time.zone.utc_to_local(time) : "---"
    end

    def get_url(obj_mail)

    	case obj_mail.class.to_s
    		
    	when PurchaseRequisition.to_s
    		url=purchase_requisition_url(obj_mail)
    	when Service.to_s
    		url=service_url(obj_mail)
    	when Project.to_s
    		url=project(obj_mail)
    	when RequisitionEntry.to_s
    		url=requisition_entry_url(obj_mail)
    	when ReMaterial.to_s
    		url=requisition_entry_url(obj_mail)#nota que es igual a requisition entry
    	when ReService.to_s
    		url=requisition_entry_url(obj_mail)#nota que es igual a requisition entry
    	else
    		url=""
    	end

    	return url 
    end

    def print_error(errors) 

    	ctt_center = content_tag(:div)

    	if(errors.any?)
    		st =""

    		errors.messages.each_with_index do |msg, i|
    			st +=content_tag(:li,msg[1][0])
    		end

    		st = st.html_safe
    	end

    	ctt_errors = content_tag(:div,st,id:'error_explanation') 

    	return content_tag(:div,ctt_errors,align:'center')

    end

    def print_as_error(error)

    	st = content_tag(:li,error.html_safe)
    	ctt_errors = content_tag(:div,st,id:'error_explanation') 
    	return content_tag(:div,ctt_errors,align:'center')
    	
    end

    def time_to_s_char(time,datetime)

    	# A veces recibo ActiveSupport::TimeWithZone y no afecta a los Date
    	datetime = datetime.to_date  

	    case time
		      when "week"
		        datetimeWished = datetime.cweek
		      when "month"
		        datetimeWished = datetime.month
		      when "trimester"
		        datetimeWished = ( (datetime.month-1) / 3).floor + 1 
		      else
		        datetimeWished = nil
	    end 

	    return datetimeWished.to_s + "-" + datetime.year.to_s

    end

    def period_to_st(index,num_of_days,num_of_periods)

    	puts "num of periods " + num_of_periods.to_s

    	if index <= -1
    		 st ="< 0"
    	elsif index >=  num_of_periods
    		st = "+ " + ((num_of_periods * num_of_days)+1).to_s
    	else
    		init_num =(index*(num_of_days+1))
    		st = init_num.to_s  + " - " + (init_num + num_of_days).to_s
    	end

    	return st	

    end

end
