
var clicked_row;

$( document ).ready(function() {


        $("#item_info_btn").click(function(){

                $('#item_info_div').slideToggle();
            }
        );


		var removeItem = function(){
			//alert("hey");
						//obtengo las rows
			tr = $(this).closest('tr');
            clicked_row = tr;
			//obtengo los tds de dicha row
			tds = tr.children('td');
			// aquiasumo que la primera es el nombre y la segunda es la descripción
			nombre = $(tds[0]).html();
			description = $(tds[1]).html();

			$("#item_name").html(nombre);
			$("#item_description").html(description);
			$("#id_p").val($(this).attr('name')); //aqui le paso el id del que se va a remover
			
			opt=$("select#item_p").children("option[value="+$(this).attr('name')+"]")
			opt.attr("disabled",true);
			$(opt).siblings().removeAttr('disabled');
			$("select#item_p").children("option[value=]").attr("selected",true);

			$("#modal_item").modal('show');
	
		};



		$('.removeItem').click(removeItem);



		$("#item_remove_form").submit(function(){

				//alert("YES");
			//PARA QUE FUNCIONE ESTO NO DEBE DE FUNCIONAR
   				console.log($(this).attr('action'));
    			console.log($(this).serialize());
    			//CHaleee
    	$.ajax({
    			url: "/items/secure_remove/",
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
                alert("Se eliminó Item." );
                $("#modal_item").modal('hide');
                clicked_row.remove();

                //$("#new-requisition_entries-field").load('#');
                //$("#modal_test").modal('hide');
                //$("new-requisition_entries-field")
                //$.get("/reload_div/", {}, null, "script" );

    		});
    	return false;



		});


	});