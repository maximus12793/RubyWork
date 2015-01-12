// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-1111
//= require jquery-ui1104min
//= require wice_grid
//= require_tree .
//= require wice_grid.js

var pilotFieldsUI = {
    init: function() {
        var association;
        $('#addButtonService').on('click', function() {
            association="services"
            formHandler.appendFields(association);
            formHandler.hideForm();
        });

        $('#cancelButtonService').on('click', function() {//Para que no se generen dobles entradas cuando cierra con el tache
            association="services"
            var inputFields = $('#new-'+association+'-field' + ' ' + cfg.inputFieldClassSelector);//"#new-services-field"
            inputFields.detach();
            formHandler.hideForm();
        });


        $('#addButtonRe').on('click', function() {
            association="requisition_entries"
            formHandler.appendFields(association);
            formHandler.hideForm();
        });

        $('#cancelButtonRe').on('click', function() {//Para que no se generen dobles entradas cuando cierra con el tache
            association="requisition_entries"
            var inputFields = $('#new-'+association+'-field' + ' ' + cfg.inputFieldClassSelector);//"#new-services-field"
            inputFields.detach();
            formHandler.hideForm();
        });

        $('#closeService').on('click', function() {//Para que no se generen dobles entradas cuando cierra con el tache
            association="services"
            var inputFields = $('#new-'+association+'-field' + ' ' + cfg.inputFieldClassSelector);//"#new-services-field"
            inputFields.detach();
            formHandler.hideForm();
        });

        $('#closeRe').on('click', function() {//Para que no se generen dobles entradas cuando cierra con el tache
            association="requisition_entries"
            var inputFields = $('#new-'+association+'-field' + ' ' + cfg.inputFieldClassSelector);//"#new-services-field"
            inputFields.detach();
            formHandler.hideForm();
        });

    }
};

var rowBuilder = function() {
    // Private property that define the default <TR> element text.
    var row = $('<tr>', { class: 'fields' });

    // Public property that describes the "Remove" link.
    var link = $('<i>', {
        href: '#',
        class: "icon-remove",
        onclick: 'remove_fields(this); return false;',
        title: 'Delete this Service.'//Abra BUgzazooooooooo==000000000000000000??
    });

    var copyLink = $('<i>', {
        href: '#',
        class: "icon-hand-down",
        onclick: 'copyRow(this); return false;',
        title: 'Copy this Service.'//Abra BUgzazooooooooo==000000000000000000??
    });

    // A private method for building a <TR> w/the required data.
    var buildRow = function(fields) {
        var newRow = row.clone();

        // $.map($(fields),function() {
        //     $(this).removeAttr('class');
        //     return $('<td/>').append($(this));
        // });//.appendTo(newRow);

        for(i=0; i< $(fields).length;i++)
        {
           $(fields)[i] = $($(fields)[i]).removeAttr('style');
     
           if ( t=$($(fields)[i]).children("label") )
           {
                t.remove();
           }

           $($(fields)[i]).children(".visible").each(function(){
                    $(this).removeAttr('style');
                }
            );
           
           new_class=$($(fields)[i]).attr('class');
           new_class= new_class.replace('field','');
           $(fields)[i]=$($(fields)[i]).attr('class',new_class);

           toApp=$('<td/>').append($($(fields)[i]));
           toApp.appendTo(newRow);
        }

        return newRow;
    }

    // A public method for building a row and attaching it to the end of a <TBODY> element.
    var attachRow = function(tableBody, fields) {
        var row = buildRow(fields);
        $(row).appendTo($(tableBody));
        return row;
    }

    // Only expose public methods/properties.
    return {
        addRow: attachRow,
        link: link,
        copyLink: copyLink
    }
}();

var formHandler = {
    // Public method for adding a new row to the table.
    appendFields: function(association) {
        // Get a handle on all the input fields in the form and detach them from the DOM (we will attach them later).
        var inputFields = $('#new-'+association+'-field' + ' ' + cfg.inputFieldClassSelector);//"#new-services-field"
        inputFields.detach();

        // Build the row and add it to the end of the table.
        r=rowBuilder.addRow(cfg.getTBodySelector(association), inputFields);

        // Add the "Remove" link to the last cell.
        link2 =rowBuilder.link.clone();
        link3 =rowBuilder.copyLink.clone();

        //link2.appendTo($('tr:last td:last'));
        link2.appendTo(r.find('td:last'));
        link3.appendTo(r.find('td:last'));
    },

    // Public method for hiding the data entry fields.
    hideForm: function() {
        $(cfg.formId).modal('hide');
    }
};

var cfg = {
    formId: '#new-services-field',//ya ni se usa!
    tableId: '#services-table',//ya ni se usa!
    inputFieldClassSelector: '.field',// UNA OPURTUNIDAD PARA BUGSASOOOOOOOOOOOOOOO
    getTBodySelector: function(association) {
        return  "#"+association+'_table  tbody';//OPORTUNIDAD DE BUGZASOOOOOOOOOOOO
    }
};

$( document ).ready(function() {
    console.log( "ready!" );
    $( ".datepicker" ).datepicker({dateFormat:"dd/mm/yy" });

    $(window).keydown(function(e){

                var evtobj = window.event? event : e;

                if (evtobj.keyCode == 78 && evtobj.ctrlKey){
                    window.location = '/purchase_requisitions/new';
                }else if(evtobj.keyCode == 77 && evtobj.ctrlKey ) {
                    window.location = '/requisition_entries';
                }else if(evtobj.keyCode == 83 && evtobj.ctrlKey ) {
                    window.location = '/services';
                }
            }

        );

    $(".today-btn").click(function(){

        //alert("YES");
        d = new Date();
        $($(this).parent().find("select")[0]).val(d.getDate());
        $($(this).parent().find("select")[1]).val(d.getMonth()+1);//Este más uno es porque a js le gusta q los meses sean de 0-11
        $($(this).parent().find("select")[2]).val(d.getFullYear());
    });

    $(".approveBut").click( function(){
            alert('Todas Partidas Aprobadas');
            $(".statusSel").each(function(){

                    $(this).val(1);
            });

    });
    

   // console.log($(".docCheckBox")[0].parents());
   $(".email-select").hide();

    $(".docCheckBox").click(function(){

            if($(this).is(':checked')){
                $(this).next().next().next().children()[0].disabled="";
            }else{
                $(this).next().next().next().children()[0].disabled="true";
            }
        }
    );

    $(".rowsSelectables").click(function() {
      //alert("Handler for .click() called.");
      window.location = '/purchase_requisitions/'+this.dataset.link;
    });

    $(".rowsSelectablesRE").click(function() {
      //alert("Handler for .click() called.");
      window.location = 'requisition_entries/'+this.dataset.link;
    });

    $(".rowsSelectablesService").click(function() {
      //alert("Handler for .click() called.");
      window.location = 'services/'+this.dataset.link;
    });

    $(".email-check").change(function(){
        s=$(this).parent().parent().find(".email-select");
       
        if ($(this).is(":checked")){
            s.show();
        }else{
            s.hide();
        }

    });

    $("#new_item").submit(function(){
    	
    	//PARA QUE FUNCIONE ESTO NO DEBE DE FUNCIONAR
   		console.log($(this).attr('action'));
    	console.log($(this).serialize());
    	//CHaleee
    	$.ajax({
    			url: $(this).attr('action'),
    			data: $(this).serialize(),
    			type: "POST",
    			dataType: "JSON",
    			timeout:300,
    			error:function(XMLHttpRequest, textStatus, errorThrown){
    				console.log("error");
    				console.log(XMLHttpRequest);
    				console.log(XMLHttpRequest.responseText);
    				var error="";
                    if (XMLHttpRequest.responseText){

        				 var jsonResponse = eval('('+XMLHttpRequest.responseText+')');

        				if(jsonResponse.name)
        					error = error +"Name "+jsonResponse.name+".\n";

        				if(jsonResponse.description)
        					error = error +"Description "+jsonResponse.description+".";

        				alert(error);
                    }else{
                       alert( XMLHttpRequest.statusText );
                    }

    			}		
    		}).success(function(json){
    			//console.log("Exitoso");
    			//console.log(json);	
    			//location.reload();
                alert("Se agregó Item nuevo.Recarga la página para poderlo usar." );
                $("#new-requisition_entries-field").load('#');
                $("#modal_test").modal('hide');
                //$("new-requisition_entries-field")
                $.get("/reload_div/", {}, null, "script" );

    		});
    	return false;
    }); 
    
    $("#status-select").change(function(){

        //alert($('#status-select').val());
        $(".status_hidden").val($('#status-select').val());

        });


});

function viewModal()
{
	console.log('view modal');
	$("#modal_test").modal('show');
};

function viewActivityModal()
{
    console.log('view modal Activity');
    $("#modal_activity").modal();
}

// function remove_fields(link)
// {
//     $(link).prev("input[type=hidden]").value ="1";
//     $(link).parent().parent().parent().hide();
// }

function remove_fields(link)
{
    var confirmar = confirm('¿Estás seguro que lo quieres eliminar?');
    if(confirmar)
    {
        $(link).prev("input[type=hidden]").val("1");
        $(link).closest(".fields").hide();
    }
        
}



function add_fields(link, association,content)
{
    var new_id = new Date().getTime();
    var regex  = new RegExp("new_" + "requisition_entry", "g");

    $(link).parent().after(content.replace(regex,new_id));
    //$("#new-"+association+"-field").modal('show');
    $("#new-requisition_entries-field").modal('show');
}

function copyValuesModifyId(original)
{
    
    clone = $(original).clone();

    originalSelects   = $(original).find('select');
    originalTextAreas = $(original).find('textarea');
    numberId = $(clone).find('input')[0].name.split("[")[2].split("]")[0];
    newId    =(new Date()).getTime() + ""

    //Copiar el Valor de los selects
    $(clone).find('select').each(function(index, item) {
         //set new select to value of old select
         item.selectedIndex =  $(originalSelects)[index].selectedIndex ;
         item.id   = item.id.replace(numberId,newId);
         item.name = item.name.replace(numberId,newId);
    });

    //Copiar el Valor de las textareas
    $(clone).find('textarea').each(function(index, item) {
         //set new select to value of old select
         item.value = originalTextAreas[index].value ;
         item.id   = item.id.replace(numberId,newId);
         item.name = item.name.replace(numberId,newId);

    });

    $(clone).find('input').each(function(index, item) {
         //set new select to value of old select
         item.id   = item.id.replace(numberId,newId);
         item.name = item.name.replace(numberId,newId);

    });

    return clone;
}

function copyRow(link)
{
    originalRow = $(link).closest(".fields");
    rowToAdd = copyValuesModifyId(originalRow);

    tbody = $(link).parents('tbody');
    rowToAdd.appendTo($(tbody));
}

function hidePR(element)
{
    st   = $("#reIndex").val();
    hide = $("#reHide")[0].checked;
    tbody = $(".reTable").children("tbody");
    rows  = $(tbody).find("tr");
    toHide = st.split(",");
    toShow = toHide;

    //Primero hago todas visibles

    for(var i =0; i < rows.length  ;i++)
    {
        entry = rows[i];
        $(entry).show();
    }

    if(st.length == 0)
        return false;

    if(hide)
    {

        for(var i =0; i < toHide.length; i++)
        {
           entry = toHide[i];
            
           row = tbody.children("#"+entry );
            if(row)
            {
                $(row).hide();
            }
        }        

    }else
    {


        for(var i =0; i < rows.length  ;i++)
        {
            row = rows[i];

            if( ! ($.inArray($(row).attr('id') + "" ,toShow) >= 0)  )//si NO está en el array
            {
                $(row).hide();
            }
        }


    }
    

    return false;
}

function validateReception(requested,recivedQuantity,id){
    
    reciving = $(".quantityRecived"+id).val();
    
    if(parseFloat(reciving) + parseFloat(recivedQuantity) > requested)
        return confirm("Cant. Recibida es mayor a la cantidad solicitada, ¿Deseas continuar?");
    else
        return true;
    
}

function noBorradores()
{
    elements = $("select[id$=_status]");

    for(i=0;i<elements.size();i++)
    {
        ele = elements[i];

        if (ele.selectedIndex == 0)//si es borrador
            return false;
        
    }

    return true;
}
function noApproved()
{
    year  = $("select[id$=_approved_date_1i]")[0].selectedIndex;
    month = $("select[id$=_approved_date_2i]")[0].selectedIndex;
    day   = $("select[id$=_approved_date_3i]")[0].selectedIndex;

    return  year == 0 || month == 0 || day == 0;

}


function checkStatuses()
{

    if(noApproved() || noBorradores())
        return true;

    x = confirm("La SC está aprobada pero una o varias partidas tienen estaus de 'Borrador'.¿Deseas continuar?");

    return x;

}
