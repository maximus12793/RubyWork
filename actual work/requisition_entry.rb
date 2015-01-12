# -*- encoding : utf-8 -*-
include ApplicationHelper

class RequisitionEntry < ActiveRecord::Base

  include ApplicationHelper

  attr_accessible :quantity,:responsible_id,:assets_attributes,:description,:type,:service_id,:supplier_ids
  attr_accessible :unit_id,:unit,:status, :comment, :document_ids,:document,:article,:observation,:pseudo_delivery_date

  belongs_to :reciver,{:class_name =>"User" ,:inverse_of => :requisition_entries, foreign_key:'reciver_id'}
  belongs_to :responsible,{class_name: "User",foreign_key:'responsible_id' }
  #belongs_to :supplier
  belongs_to :item
  belongs_to :unit
  belongs_to :service
  belongs_to :purchase_requisition, :inverse_of => :requisition_entries

  has_and_belongs_to_many :suppliers

  #self.inheritance_column = :_type_disabled ME SIRVE PARA CUANDO DICE QUE EL STI NO FUNCIONA


  validates :quantity, numericality: { message: "Partida Materiales:'Cantidad' debe ser un número" } , presence:{ message: "Partida Materiales: Debes solicitar cierta 'Cantidad'" }  
  #validates :price,    numericality: { message: "Partida Materiales:'Precio' debe ser un número" } , allow_nil: true 
  
  validates :unit_id,     presence: { message: "Partida Materiales: Debe ingresar unidades." }
  validates :description, presence: { message: "Partida Materiales: Debe ingresar un artículo." }
  validates :status,      presence: { message: "Partida Materiales: Elige un estatus!" }
  
#  validates :remision_number, numericality: { message: "'# Remisión' debe ser un número" } , allow_nil: true 
#  validates :bill_number, numericality: { message: "'# Factura' debe ser un número" } , allow_nil: true 
  validates :supp_quantity, numericality: { message: "Partida Materiales: 'Cant. Suministrada' debe ser un número" } , allow_nil: true 

  validate  :has_valid_status?
  validate  :has_valid_status_with_suppliers?

  has_many :assets
  has_many :receptions, :foreign_key => 'requisition_entry_id', :class_name => 'Reception'
  accepts_nested_attributes_for :assets

  #has_and_belongs_to_many :documents

  acts_as_commentable

  audited :allow_mass_assignment => true
  #after_update :notify_responsible           #YA NO LO ENVIO AQUí PORQUE  lo envio en todos lados al responsable
  before_destroy :before_destroy

  include ApplicationHelper
  include ActionView::Helpers::TextHelper# si no puedes usar el truncate aunque este en el helper :S


  def has_valid_status?
    #STATUSES     = ['Borrador', 'Aprobado','Asign. a Comprador','Faltan Esp.','Solicitado a Prov.','Entregado en Almacén','Recibido Parcial','Recibido total','Rechazada','Devuelto a Prov.','Facturado','Cancelado']# el ultimo es el 11 empieza en 0
    #                    0           1              2               3                4                    5                       6                 7             8                   9        10            12         
    if(self.supp_quantity > 0.0 && self.status < 6 )
      errors.add(:estatus, " debe ser superior a 'Recibido Parcial' ")
    end

    if( !self.pseudo_delivery_date && self.status == STATUSES.index('Solicitado a Prov.')   && self.created_at.to_date >= Date.parse("14-05-14") )
      errors.add(:solicitud_de_compra, "  debe tener F.E. Compras")
    end

  end

  def has_valid_status_with_suppliers?
    #Es la fecha a partir de la cual aplica este filtro(14-04-11) 2014-abril-11

    if(self.suppliers.count == 0 && self.status == STATUSES.index('Solicitado a Prov.')   && self.created_at.to_date >= Date.parse("14-04-11") )
      errors.add(:estatus, " debe seleccionar mínimo un Posible Proveedor. ")
    end

  end

  def audits_ordered
    self.audits
  end
  def reject_items(attributed)
    attributed['id'].blank?
  end

  def print_id
    p_null(self.id)
  end
  def print_sc
    p_null(self.purchase_requisition_id)
  end
  def print_item
    p_item(self.item_id)
  end
  def print_quantity
    p_null(self.quantity)
  end
  def print_unit
    p_units(self.unit_id)
  end

  def print_filled_form_date
    p_null(self.purchase_requisition.created_at) if self.purchase_requisition
  end

  def print_description
    p_comments(self.description)
  end
  def print_supp_quantity
    p_null(self.supp_quantity)
  end
  def print_quantity_to_supply
    p_null(self.quantity_to_supply)
  end
  def print_reciver
    p_user(self.reciver)
  end
  def print_remision_number
    p_null(self.remision_number)
  end
  def print_recived_date
    p_null(self.recived_date)
  end
  def print_supplier
    p_supplier(self.supplier)
  end
  
  def print_posible_suppliers
    p_posible_suppliers(self.suppliers)
  end

  def print_bill_number
    p_null(self.bill_number)
  end
  def print_document
    p_null(self.document)
  end
  def print_responsible
    p_user(self.responsible_id)
  end
  def print_price
    p_null(self.price)
  end
  def print_status
    p_sts(self.status)
  end

  def print_observation
    p_comments(self.observation)
  end

  def quantity_to_supply

      if(self.supp_quantity && self.quantity )
          self.quantity - self.supp_quantity
      else
          self.quantity
      end

  end

  def expired?

      #recived_statuses = [5,7,8,9]; #Recibido Parcial(5),'Rechazada'(7),'Devuelto a Prov.'(8),'Inspeción Cal.'(9)

      if ! self.purchase_requisition
        return false
      end

      ban1 = self.purchase_requisition.requested_date < Date.today if (self.purchase_requisition.requested_date)
      #STATUSES     = ['Borrador', 'Aprobado','Asign. a Comprador','Faltan Esp.','Solicitado a Prov.','Entregado en Almacén','Recibido Parcial','Recibido total','Rechazada','Devuelto a Prov.','Facturado','Cancelado','Error de Estatus']# el ultimo es el 11 empieza en 0
      ban2 = self.status <= 4 # si es mayor al status de  recibida en alamacen....parcial recibida no deberia ser expirada 

      return ban1 && ban2 

  end

  def set_expired
        
        correct_ban_val = self.expired? 
        
        if self.expired != correct_ban_val
            self.expired = correct_ban_val
            self.save
        end
        
  end

  def self.all_expired

      all=RequisitionEntry.all
      expireds= []

      all.each do |re|
        expireds << re if re.expired?
      end

      return expireds

  end

  def self.set_expireds

      RequisitionEntry.all.each do |re|
        re.set_expired
      end

  end

  def self.at_status(index)

      if index.class == String && index != "0"
        index = index.to_i > 0 ? index.to_i : "---"
      elsif index =="0"
        index = index.to_i
      end

      return nil if index.class != Fixnum

      arr=[] 
      RequisitionEntry.all.each do |ser|
        arr << ser if ser.status == index
      end  

      return arr

  end


  def self.array_of_statuses
      
      ser_status = []
      
      STATUSES.length.times do |i|
         ser_status << RequisitionEntry.at_status(i)
      end 

      return ser_status

  end


  def self.array_per_supplier

      h= Hash.new 
      Supplier.all.each do |s|
          h[s] =  s.requisition_entries.count
      end

  end

   def self.array_per_responsible

      h= Hash.new 
      User.all.each do |u|
          h[u] =  u.requisition_entries_resp.count
      end

  end

  def identifier

      begin
        pr = self.purchase_requisition

        st = pr.id.to_s + "." +  (pr.requisition_entries.sort_by { |a| a.created_at}.index(self)+1).to_s
        st += self.class == ReService ? "-S" : "-M"  

        return st + " (" +self.id.to_s + ")" 
      rescue
        return "0"
      ensure
        
      end
      
  end
  
  def has_changed?
    
    if self.audits.count > 0 

            delta_time = Time.now - self.audits.last.created_at
            a_change = delta_time < 30 #&& delta_time>0  #han pasado menos de 15 segundos (a menos que haya sido creado en el futuro)
            return a_change
    end

    return false
  end


  def responsible_and_buyer
      arr= []

      if self.responsible
        arr << self.responsible_id
      end

      if self.purchase_requisition.buyer 
        arr << self.purchase_requisition.buyer_id if self.purchase_requisition.buyer
      end

      return arr
  end



  #Metodos para calcular variables que dependen de las receptions

  def supp_quantity  

      supp_quantity = 0.0
        
      self.receptions.each do |mr|
          supp_quantity += mr.quantity ? mr.quantity : 0.0 # en caso de que no se haya definido el quantity
      end

      return supp_quantity

  end

  def price  
    average(self.receptions, :price)
  end

  def recived_date  

      all_are_equal(self.receptions, :recived_date)
  end

  def bill_number  

      all_are_equal(self.receptions, :bill_number)
  end

  def remision_number  
      all_are_equal(self.receptions, :remision_number)
  end

  def reciver  
      all_are_equal(self.receptions, :reciver)
  end
  def supplier  
      all_are_equal(self.receptions, :supplier)
  end
  
  def real_reception_date #Todas las partidas deben de estar o en "Recepción Total" o como "Facturado"
      real_reception = nil
       
      return nil if !self.total_reception?  #Recibido total 

      self.receptions.each do |reception|
          rec_date = reception.recived_date
          real_reception = rec_date  if (!real_reception || real_reception < rec_date )
      end

      return real_reception
  end

  def total_reception?

    return self.status == 7  || self.status == 10

  end

  def real_reception_date_show_version #Todas las partidas deben de estar o en "Recepción Total" o como "Facturado"
    #return "_f"
    return "---" if !self.real_reception_date

    st = p_null self.real_reception_date
    #puts pr.id.to_s
    return "---" if !self.purchase_requisition 
    rd =  self.purchase_requisition.requested_date

    if rd < self.real_reception_date
      color = "redBackGround"
    elsif  rd.to_s ==  self.real_reception_date.to_s
      color = "yellowBackGround"
    else # estamos en verde
       color = "greenBackGround"
    end

    st = st  + content_tag(:div ,nil, class: "#{color} semaphoreBox")

    return st.html_safe

  end

  def recived_late?

      return false if !self.purchase_requisition || !self.real_reception_date

      rd =  self.purchase_requisition.requested_date

      return rd < self.real_reception_date 
  end

  def recived_on_time?

      return false if !self.purchase_requisition || !self.real_reception_date
      rd =  self.purchase_requisition.requested_date

      return rd == self.real_reception_date 

  end

  def recived_before?

      return false if !self.purchase_requisition || !self.real_reception_date
      rd =  self.purchase_requisition.requested_date

      return rd > self.real_reception_date 
    
  end

  def self.recived_late
      result = []

      RequisitionEntry.all.each do |re|
         result << re if re.recived_late?
      end

      return result  
  end

  def self.recived_before
      result = []

      RequisitionEntry.all.each do |re|
         result << re if re.recived_before?
      end

      return result  
  end

  def self.recived_on_time
      result = []

      RequisitionEntry.all.each do |re|
         result << re if re.recived_on_time?
      end

      return result  
  end

  def self.hash_by_recived_date(initDate =  nil , endDate =  nil )

    initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
    endDate  = endDate ? Date.parse(endDate)    : Date.today
    
    h = Hash.new

    h[:recived_late]    = []
    h[:recived_before]  = []
    h[:recived_on_time] = []

    RequisitionEntry.where(:created_at=>initDate..endDate).each do |re|
         h[:recived_on_time] << re if re.recived_on_time?
         h[:recived_before]  << re if re.recived_before?
         h[:recived_late]    << re if re.recived_late?

    end

    return h

  end


  def before_destroy
    if ! self.destroyable?
      errors.add(:base, "El estatus no permite eliminar estatus." )
      return false
    end
       
  end

  def destroyable?
    return  !( self.status >= STATUSES.index("Asign. a Comprador") )
  end

  def requested_date
       
       return self.purchase_requisition.requested_date if self.purchase_requisition

       return nil

  end


  def trimester
    (self.created_at.month / 3).floor + 1 
  end



  private

  def average(array,message)

    if array.count <=0
          return nil
    else

      sum = 0.0
      array.each do |mr|
          sum += mr.send(message) if mr.send(message).class == BigDecimal
      end

      return sum / array.count

    end

  end

    def all_are_equal(array,message)

      if array.count <=0
          return nil
      else
          first_obj = array.first.send(message)
          
          if first_obj == nil
            return nil
          end

          array.each do |mr|

            to_compare    =  mr.send(message)

            if first_obj != to_compare && to_compare
              return nil
            end

          end
          # si logro salir de ese for es porque todos eran el mismo precio
          return first_obj
      end 
    end

  def notify_responsible
    #YA NO LO ENVIO AQUí PORQUE  lo envio en todos lados al responsable

    #AQUI ES IDEAL PARA ENVIAR EL CORREO
    if self.responsible
        UserMailer.assigned_entry_or_service(self.audits.last.user,self).deliver
    end
  end

  def self.search(terms = "")
        sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
        RequisitionEntry.where("search_vector @@  #{sanitized}")
  end

  def self.specialSearch(terms = "", expired = "" )

        terms = "" if terms ==nil
        expired = "" if expired ==nil
        
        return RequisitionEntry if(terms =="" && expired == "")

        if (expired == "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized}")
        elsif (expired != "" && terms =="")
           return RequisitionEntry.where(expired:true)
        elsif (expired != "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized} AND expired = true")
        end  
  end

   def self.specialSearchCompleted(terms = "", expired = "" )

        terms = "" if terms ==nil
        expired = "" if expired ==nil
        
        return RequisitionEntry.where("status >= ?",STATUSES.index("Recibido total")) if(terms =="" && expired == "")

        if (expired == "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized} AND status >= ?",STATUSES.index("Recibido total"))
        elsif (expired != "" && terms =="")
           return RequisitionEntry.where("expired = true AND status >= ?",STATUSES.index("Recibido total"))
        elsif (expired != "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized} AND expired = true AND status >= ?",STATUSES.index("Recibido total"))
        end  
  end

  def self.specialSearchINCompleted(terms = "", expired = "" )

        terms = "" if terms ==nil
        expired = "" if expired ==nil
        
        return RequisitionEntry.where("status < ?",STATUSES.index("Recibido total")) if(terms =="" && expired == "")

        if (expired == "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized} AND status < ?",STATUSES.index("Recibido total"))
        elsif (expired != "" && terms =="")
           return RequisitionEntry.where("expired = true AND status < ?",STATUSES.index("Recibido total"))
        elsif (expired != "" && terms !="")
           sanitized = sanitize_sql_array(["to_tsquery('spanish', ?)", terms.gsub(/\s/,"+") + ":*"])
           return RequisitionEntry.where("search_vector @@  #{sanitized} AND expired = true AND status < ?",STATUSES.index("Recibido total"))
        end  
  end

  def self.per_status
     arr = Array.new(STATUSES.count,0)

     RequisitionEntry.all.each do |re|
      arr[re.status] =  arr[re.status] + 1   if re.status && re.status >=0 && re.status < STATUSES.count 
     end

     return arr

  end

  def self.hash_real_delivered_date_per(time,initDate,endDate)
      
      h = Hash.new

      #No pongo a partir de la fecha solicitada 
      #porque no afuerza la de menor id tiene la fecha requerida más próxima 

      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate ? Date.parse(endDate)    : Date.today
      
      RequisitionEntry.re_between_dates(initDate,endDate).sort_by{|x| x.requested_date }.each do |re|
          datetime =  re.requested_date     

          date = time_to_s_char(time,datetime)
      
          if (! h[date])
            
            inner_hash = {"onTime" =>0,"delayed"=>0,"anticiped"=>0,"noDelivered"=>0}
            h[date] =  inner_hash

          end

          inner_hash = h[date]

          label = re.recived_late? ? "delayed" : (re.recived_on_time? ? "onTime" : ( re.recived_before? ? "anticiped" : "noDelivered" )  )

          inner_hash[label] = inner_hash[label] + 1

      end    

      return h
      
  end

  def self.hash_days_delayed(time,initDate = nil,endDate = nil )

      h = Hash.new
      auxDaysDelayed = Hash.new
      h_result = Hash.new
      
      #No pongo a partir de la fecha solicitada 
      #porque no afuerza la de menor id tiene la fecha requerida más próxima 

      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate ? Date.parse(endDate)    : Date.today
      
      puts initDate
      puts endDate

      RequisitionEntry.re_between_dates(initDate,endDate).each do |re|
        
        next if !re.real_reception_date       

        date = ApplicationHelper.time_to_s_char(time,re.requested_date )
        
        h[date] = h[date] ?  h[date] + 1 : 1 #está el acumulado 


        days_delayed =  (re.requested_date - re.real_reception_date).to_i 

        auxDaysDelayed[date] = 0 if !auxDaysDelayed[date]
        auxDaysDelayed[date] = auxDaysDelayed[date] + days_delayed

      end


      #lleno un tercer Hash donde  divido el acumulado de dias entre 
      #la canitdad de dias

      h.each do |key,value| 
        h_result[key] = Float(auxDaysDelayed[key]) / Float(value) 
      end 

      return h_result

  end

  #Regresa las partidas que fueron requeridas para cierto tiempo
  def self.re_between_dates(initDate,endDate)

      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate ? Date.parse(endDate)    : Date.today

      a = Array.new
      self.all.each do |re|
         a << re  if re.requested_date >= initDate && re.requested_date <= endDate
      end 

      return a

  end


  def self.re_per_status_group(initDate = nil,endDate = nil)

      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate ? Date.parse(endDate)    : Date.today

      h = Hash.new

      expired_arr         = Array.new
      total_reception_arr = Array.new
      active_arr          = Array.new

      

      RequisitionEntry.where(:created_at=>initDate..endDate).each do |re|

          if re.expired?
            expired_arr << re
          elsif re.total_reception?
            total_reception_arr << re
          else
            active_arr << re
          end

      end

      h['expired'] = expired_arr
      h['active']  = active_arr
      h['recived'] = total_reception_arr

      return h

  end

  def self.expired_with_status(status = nil, initDate =  nil , endDate =  nil )

      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate ? Date.parse(endDate)    : Date.today

      arr= Array.new

      RequisitionEntry.where(:created_at=>initDate..endDate).each do |re|
         arr << re if re.expired? && (!status || status == re.status )
      end

      return arr

  end

  def self.delayed_days(initDate,endDate,num_of_days,num_of_periods)

    initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
    endDate  = endDate  ? Date.parse(endDate)   : Date.today

    num_of_days    =  3 if !num_of_days 
    num_of_periods =  3 if !num_of_periods 

     h = Hash.new

    (-1..num_of_periods).each do |i|
      h[i] = Array.new()
    end

    RequisitionEntry.where(:created_at=>initDate..endDate).each do |re|

      next if !re.real_reception_date
      days_delayed =  (re.requested_date - re.real_reception_date).to_i 

      relation = ( days_delayed / (num_of_days+1) ) 

      index    = relation < num_of_periods ? relation : num_of_periods
      index = -1 if index < 0

      h[index] << re

    end

    return h 
  end

  def self.delayed_days_numbers(initDate = nil ,endDate = nil ,num_of_days = 3,num_of_periods = 3)

    num_of_days    =  3 if !num_of_days 
    num_of_periods =  3 if !num_of_periods 

    hash = RequisitionEntry.delayed_days(initDate,endDate,num_of_days,num_of_periods)

    new_hash = Hash.new

    hash.keys.each do |key|

      new_key = ApplicationHelper.period_to_st(key,num_of_days,num_of_periods)

      new_hash[new_key] = hash[key].count 

    end

    return new_hash

  end

  def self.stadistics_by_user(initDate = nil,endDate= nil ,user_id)
    
      initDate = initDate ? Date.parse(initDate)  : RequisitionEntry.first.created_at.to_date   
      endDate  = endDate  ? Date.parse(endDate)   : Date.today

      h = Hash.new 

      if User.exists?(user_id)

         u = User.find(user_id)

         h['Expiradas']  = Array.new
         h['Activas']    = Array.new
         h['Tardia']     = Array.new
         h['A tiempo']   = Array.new
         h['Anticipada'] = Array.new

         u.purchase_requisitions_as_buyer.each do |pr|
            pr.requisition_entries.where(:created_at=>initDate..endDate).each do |re|

               if re.expired?
                  h['Expiradas'] << re
               elsif re.real_reception_date

                  
                  h['Tardia']     << re if re.recived_late?
                  h['A tiempo']   << re if re.recived_on_time?
                  h['Anticipada'] << re if re.recived_before?

               else 
                  h['Activas'] << re
               end

            end

         end
      end

      return h
  end

end
