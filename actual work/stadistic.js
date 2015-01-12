function drawChartRE(material,service) 
{
	var data = new google.visualization.DataTable();

        data.addColumn('string', 'Partida');
        data.addColumn('number', 'Tipo');
        data.addRows([
          ['Materiales', material],
          ['Servicios', service]
        ]);

        var options = {'title':'Partidas',
                       'width':740,
                       'height':500,
                   	   'is3D': true	};
        var chart = new google.visualization.PieChart(document.getElementById('re_chart_div'));
        chart.draw(data, options);

}
function drawChartRERecivedDate(onTime,before,late) 
{
	var data = new google.visualization.DataTable();

        data.addColumn('string', 'Estado');
        data.addColumn('number', 'Total');
        data.addRows([
          ['En tiempo', onTime],
          ['Anticipada', before],
          ['Atrasada', late]
        ]);

        var options = {'title':'Partidas F.E. Real',
                       'width':740,
                       'height':500,
                   	   'colors':['#F7EC14','#31B404','#EB491B'],
                   	   'is3D': true	};
        var chart = new google.visualization.PieChart(document.getElementById('re_fer_chart_div'));
        chart.draw(data, options);

}
function drawChartPRRecivedDate(onTime,before,late) 
{
	var data = new google.visualization.DataTable();

        data.addColumn('string', 'Estado');
        data.addColumn('number', 'Total');
        data.addRows([
          ['En tiempo', onTime],
          ['Anticipada', before],
          ['Atrasada', late]
        ]);

        var options = {'title':'SC F.E. Real',
                       'width':740,
                       'height':500,
                   	   'colors':['#F7EC14','#31B404','#EB491B'],
                   	   'is3D': true	};
        var chart = new google.visualization.PieChart(document.getElementById('pr_fer_chart_div'));
        chart.draw(data, options);

}
function drawChartTimeEnlapsed(days_relations_materials,days_relations_services)
{
	//statuses = viene el nombre de los statuses en un JSON
	//quantities
	var data = new google.visualization.DataTable();

	data.addColumn('number', '# de días');
	data.addColumn('number', '# de Partidas Materiales');
	data.addColumn('number', '# de Partidas Servicios');
	//data.addColumn({role:'style'});
	

	for(var i = 0; i < days_relations_materials.length; i ++ )
	{
		data.addRow([ days_relations_materials[i][0],days_relations_materials[i][1] ,0]);
	}

	for(var i = 0; i < days_relations_services.length; i ++ )
	{
		data.addRow([ days_relations_services[i][0],0,days_relations_services[i][1] ]);
	}

	var options = {
          title: 'Días de atraso',
          hAxis: {title: 'Días de atraso', titleTextStyle: {color: 'blue'}},
          'width': 840,
          'height':500
        };

	var chart = new google.visualization.ColumnChart(document.getElementById('enlapsed_chart_div'));
    chart.draw(data, options);
} 


function drawChartStatuses(statuses,quantities_re,quantities_ser,colors)
{
	//statuses = viene el nombre de los statuses en un JSON
	//quantities
	var data = new google.visualization.DataTable();

	data.addColumn('string', 'Status');
	data.addColumn('number', 'Partidas Materiales');
	data.addColumn({ type:'string',role: 'style' });
	data.addColumn('number', 'Partidas Servicios');
	//data.addColumn('string',{ role: 'style' });
	data.addColumn({ type:'string',role: 'style' });

	for(var i = 0; i < statuses.length; i ++ )
	{
		data.addRow([ statuses[i], quantities_re[i], colors[i] ,quantities_ser[i], colors[i] ]);
	}

	var options = {
          title: 'Partidas por Estatus',
          hAxis: {title: 'Estatus', titleTextStyle: {color: 'blue'}},
          'width': 840,
          'height':500,
          legend: {position: 'none'},
          isStacked: false
        };

	var chart = new google.visualization.ColumnChart(document.getElementById('status_chart_div'));
    chart.draw(data, options);
} 

function post(url,data)
{
  result = null;
  $.ajax({
          url: url,
          async: false,
          data: data,
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

          result = json;

        });

        return result;
}


function drawHistTotalSC(time,initDate,endDate)
{
    var data = new google.visualization.DataTable();

    data.addColumn('string', 'Tiempo');    
    data.addColumn('number', 'Solicitudes de Compra');

    url = "/stadistic/totalHistoryPR";

    values = post(url,{time:time,initDate:initDate,endDate:endDate });
    text   = toSpanish(time);

    if(! values)
        return;

    var keys = Object.keys(values); 
    for(var i = 0; i<keys.length; i++ )
    {
        k = keys[i]; 
       data.addRow([k,values[k]]);
       
    }


    var options = {
          title: 'Solicitudes de Compra',
          hAxis: {title: text, titleTextStyle: {color: 'blue'}},
          'width': 840,
          'height':500,
          legend: {position: 'none'},
          isStacked: false
        };

    var chart = new google.visualization.ColumnChart(document.getElementById('hist_chart_div'));
    chart.draw(data, options);


}

function drawHistTotalRE(time,initDate,endDate)
{
    var data = new google.visualization.DataTable();

    data.addColumn('string', 'Tiempo');    
    data.addColumn('number', 'Partida Materiales');
    data.addColumn('number', 'Partida Servicio');

    url = "/stadistic/totalHistoryRE";

    values = post(url,{time:time,initDate:initDate,endDate:endDate });
    text   = toSpanish(time);

    if(! values)
        return;

    var values1 = JSON.parse(values[0]);
    var values2 = JSON.parse(values[1]);

    var keys1 = Object.keys( JSON.parse(values[0]) );
    var keys2 = Object.keys( JSON.parse(values[1]) );

    for(var i = 0; i<keys1.length; i++ )
    {
        k = keys1[i]; 
       data.addRow([k,values1[k],null]);
    }

    for(var i = 0; i<keys2.length; i++ )
    {
        k = keys2[i]; 
        
        row = data.getFilteredRows([{column:0, value: k }]); 

        if(row.length == 0 )
            data.addRow([k,null,values2[k]]);
        else
          data.setCell(row[0],2,values2[k]);
    }

    var options = {
          title: 'Partidas',
          hAxis: {title: text, titleTextStyle: {color: 'blue'}},
          'width': 840,
          'height':500,
          legend: {position: 'none'},
          isStacked: false
        };

    data.sort({column: 0});  

    var chart = new google.visualization.ColumnChart(document.getElementById('hist_chart_div'));
    chart.draw(data, options);


}

function drawHistDateRE(time,initDate,endDate)
{
  var data = new google.visualization.DataTable();

  data.addColumn('string', 'Tiempo');    
  data.addColumn('number', 'Anticipadas');
  data.addColumn('number', 'En Tiempo');
  data.addColumn('number', 'Atrasadas');
  data.addColumn('number', 'No Entregadas');

  url = "/stadistic/dateHistoryRE";

  values = post(url,{time:time,initDate:initDate,endDate:endDate });
  text   = toSpanish(time);

  if(! values)
      return;

   var keys = Object.keys(values); 
   
   for(var i = 0; i<keys.length; i++ )
   {
      k = keys[i]; 
      data.addRow([k,values[k].anticiped,values[k].onTime,values[k].delayed,values[k].noDelivered]);
   }

   var options = {
         title: 'Partidas',
         hAxis: {title: text, titleTextStyle: {color: 'blue'}},
         'width': 840,
         'height':500,
         'colors':['#F7EC14','#31B404','#EB491B','#FF0000'],
         legend: {position: 'none'},
         isStacked: false
       };

    var chart = new google.visualization.ColumnChart(document.getElementById('hist_chart_div'));
    chart.draw(data, options);    
}

function drawHistDateSC(time,initDate,endDate)
{
    var data = new google.visualization.DataTable();

    data.addColumn('string', 'Tiempo');    
    data.addColumn('number', 'Anticipadas');
    data.addColumn('number', 'En Tiempo');
    data.addColumn('number', 'Atrasadas');
    data.addColumn('number', 'No Entregadas');
   
    url = "/stadistic/dateHistoryPR";

    values = post(url,{time:time,initDate:initDate,endDate:endDate });
    text   = toSpanish(time);

    if(! values)
        return;

    var keys = Object.keys(values); 

    for(var i = 0; i<keys.length; i++ )
    {
       k = keys[i]; 
       data.addRow([k,values[k].anticiped,values[k].onTime,values[k].delayed,values[k].noDelivered]);
       
    }

    var options = {
          title: 'Solicitudes de Compras',
          hAxis: {title: text, titleTextStyle: {color: 'blue'}},
          'width': 840,
          'height':500,
          'colors':['#F7EC14','#31B404','#EB491B','#FF0000'],
          legend: {position: 'none'},
          isStacked: false
        };

    var chart = new google.visualization.ColumnChart(document.getElementById('hist_chart_div'));
    chart.draw(data, options);


}

function toSpanish(word)
{

  switch(word)
  {
      case "week":
         text   = "Semanas";
      break;
      case "month":
          text   = "Meses";
      break;
      case "trimester":
           text  = "Trimestres";
      break;
      case "recived_late":
           text   = "Recepción Atrasada";
      break;
      case "recived_before":
          text   = "Recepción Anticipada";
      break;
      case "recived_on_time":
          text   = "Recepción en tiempo";
          
      break;
  }

  return text;

}


function drawHistDelayedDats(time,initDate,endDate)
{
  var data = new google.visualization.DataTable();

  data.addColumn('string', 'Tiempo');    
  data.addColumn('number', 'Promedio días atrasados');
  
  url = "/stadistic/averageDaysDelayed";

  values = post(url,{time:time,initDate:initDate,endDate:endDate });
  text = toSpanish(time)


  if(! values)
      return;

  var keys = Object.keys(values); 

  for(var i = 0; i<keys.length; i++ )
  {
     k = keys[i]; 
     data.addRow([k,values[k]]);
     
  }

  var options = {
        title: 'Partidas Días atrasados',
        hAxis: {title: text, titleTextStyle: {color: 'blue'}},
        'width': 840,
        'height':500,
        'colors':['#F7EC14','#31B404','#EB491B','#FF0000'],
        legend: {position: 'none'},
        isStacked: false
      };
   data.sort({column: 0});    

  var chart = new google.visualization.ColumnChart(document.getElementById('hist_chart_div'));
  chart.draw(data, options);


}

function calculateHistoryGraph()
{

  var type = $('#typeChart').val();
  var time = $('#timeGraph').val();
  var initDate = $('#initDate').val();
  var endDate  = $('#endDate').val();

  switch(type)
  {
    case "histTotalesSC":
          drawHistTotalSC(time,initDate,endDate);
    break;

    case "histTotalesRE":
          drawHistTotalRE(time,initDate,endDate);
    break;

    case "histFechaSC":
        drawHistDateSC(time,initDate,endDate);
    break;

    case "histFechaRE":
        drawHistDateRE(time,initDate,endDate);
    break;

    case "histDelayedDays":
         drawHistDelayedDats(time,initDate,endDate);
    break;

  }

}

function calculateKPIGraph()
{

  var type       = $('#kpiTypeChart').val();
  var initDate   = $('#kpiInitDate').val();
  var endDate    = $('#kpiEndDate').val();

  $('#kpiPeriods').hide();
  $('#kpiBuyers').hide();

  switch(type)
  {
    case "kpiTotalesRE":
          drawKPITotalRE(initDate,endDate);
    break;

    case "kpiStateRE":
          drawKPIstateRE(initDate,endDate);
    break;

    case "kpiAllStatusRE":
          drawKPIstatusRE(initDate,endDate);
    break;

    case "kpiAproveVSRequire":
          var num_of_per = getAndSet('#kpiPeriod');
          var dur_of_per = getAndSet('#daysPerPeriod'); 
          $('#kpiPeriods').show();

          drawKPIfaVSfer(initDate,endDate,dur_of_per,num_of_per);
    break;

    case  "distriSC":
          var buyersIds = $('#buyersSelect').val() || [];
          $('#kpiBuyers').show();

          drawKPIdistSC(initDate,endDate,buyersIds);
    break;

    case "kpiStatusExpired":

        drawKPIstatusExpired(initDate,endDate);
    break;
    case "kpiRETimeResp":
        drawKPIReTimeResp(initDate,endDate);
    break;
    case "kpiDelayedDays":
        var num_of_per = getAndSet('#kpiPeriod');
        var dur_of_per = getAndSet('#daysPerPeriod'); 
         $('#kpiPeriods').show();

        drawKPIDelayedDays(initDate,endDate,dur_of_per,num_of_per);
    break;

    case "kpiREByUser":
      var userID = $('#buyersSelect').val() || [];
      $('#kpiBuyers').show();

      drawKPIkpiREByUser(initDate,endDate,userID);
    break;
  }

}

function getAndSet(st)
{
        var num = parseInt($(st).val());
        if ( isNaN(num)  )
          {
            num = 3;
            $(st).val("3");
          }  
        return num;  
}

// FUNCIONES IMPRIMIR KPIs
function drawKPITotalRE(initDate,endDate)
{
  var data = new google.visualization.DataTable();

  data.addColumn('string', 'Partida');
  data.addColumn('number', 'Cantidad');

  url = "/stadistic/kpiRE";

  values = post(url,{initDate:initDate,endDate:endDate });

  if(! values)
      return;

  data.addRows([
    ['Materiales', values['re_materials']],
    ['Servicios', values['re_services'] ]
  ]);

  var st = 'Partidas (Total SC: ' + values['total_sc'] +" )";
  drawPieGraph(data,st);

}

function drawKPIstateRE(initDate,endDate)
{
  var data = new google.visualization.DataTable();

  data.addColumn('string', 'Estatus');
  data.addColumn('number', 'Cantidad');

  url = "/stadistic/kpiStatesRE";

  values = post(url,{initDate:initDate,endDate:endDate });

  if(! values)
      return;

  data.addRows([
    ['Activas', values['active']],
    ['Expiradas', values['expired'] ],
    ['Recibidas Totales', values['recived'] ]
  ]);

  drawPieGraph(data,'Partidas por ESTADO ');
}

function drawKPIstatusRE(initDate,endDate)
{
    var data = new google.visualization.DataTable();

    data.addColumn('string', 'Status');
    data.addColumn('number', 'Partidas Materiales');
    data.addColumn({ type:'string',role: 'style' });
    data.addColumn('number', 'Partidas Servicios');
    data.addColumn({ type:'string',role: 'style' });

    url = "/stadistic/kpiStatusRE";

    values = post(url,{initDate:initDate,endDate:endDate });

    if(! values)
        return;

    for(var i = 0; i < values['status'].length; i ++ )
    {
      data.addRow([ values['status'][i], values['reMaterial'][i], values['colors'][i] ,values['reService'][i], values['colors'][i] ]);
    }


    var view = new google.visualization.DataView(data);
      view.setColumns([0, 1,
                       { calc: "stringify",
                         sourceColumn: 1,
                         type: "string",
                         role: "annotation" },
                       2,3,
                       { calc: "stringify",
                         sourceColumn: 3,
                         type: "string",
                         role: "annotation" },
                       4]);

    var options = {
            title: 'Partidas por Estatus',
            hAxis: {title: 'Estatus', titleTextStyle: {color: 'blue'}},
            'width': 840,
            'height':500,
            legend: {position: 'none'},
            isStacked: false
          };

    var chart = new google.visualization.ColumnChart(document.getElementById('kpi_chart_div'));
      chart.draw(view, options);
}

function drawKPIfaVSfer(initDate,endDate,dur_of_per,num_of_per)
{
    var data = new google.visualization.DataTable();

    url = "/stadistic/kpiFaVSFER";

    values = post(url,{initDate:initDate,endDate:endDate,num_of_days:dur_of_per,num_of_periods:num_of_per });

    if(! values)
        return;

    data.addColumn('string', 'Periodo');
    data.addColumn('number', 'Cantidad'); 

    var keys = Object.keys(values); 

    for(var i = 0; i < keys.length; i++ )
    {
      data.addRow([ keys[i] + " días.", values[keys[i]] ]);
    }

    drawPieGraph(data,'Tiempos de Entrega Requeridos');

}
function drawKPIdistSC(initDate,endDate,buyersIds)
{

  var data = new google.visualization.DataTable();
  url = "/stadistic/scPerUser";

  data.addColumn('string', 'Nombre');
  data.addColumn('number', 'Cantidad');

  for(var i = 0; i < buyersIds.length; i++ )
  {
    values = post(url,{initDate:initDate,endDate:endDate,buyerID:buyersIds[i] });

    name     = values['name'];
    quantity = parseInt(values['quantity'])
    
    if(!isNaN(quantity) && name.length > 0 )
      data.addRow([ name, quantity]);
  } 

  drawPieGraph(data,'Distribución de SC');
}

function drawKPIstatusExpired(initDate,endDate)
{
  var data = new google.visualization.DataTable();
  url = "/stadistic/statusExp";

  values = post(url,{initDate:initDate,endDate:endDate });

  data.addColumn('string', 'Estatus');
  data.addColumn('number', 'Cantidad');

  var keys = Object.keys(values); 

  for(var i = 0; i < keys.length; i++ )
  {
    data.addRow([ keys[i] , values[keys[i]] ]);
  }

    drawPieGraph(data,'Estatus de Partidas Expiradas');

}
function drawKPIReTimeResp(initDate,endDate)
{
  var data = new google.visualization.DataTable();

  url = "/stadistic/kpiReTimeResp";
  values = post(url,{initDate:initDate,endDate:endDate });

  data.addColumn('string', 'Estatus');
  data.addColumn('number', 'Cantidad');

  var keys = Object.keys(values); 

  for(var i = 0; i < keys.length; i++ )
  {
    data.addRow([ toSpanish(keys[i]) , values[keys[i]].length ]);
  }

    drawPieGraph(data,'Cumplimiento de Partidas Recibidas');

}

function drawKPIDelayedDays(initDate,endDate,dur_of_per,num_of_per)
{
    var data = new google.visualization.DataTable();

    url = "/stadistic/kpiDelayedDays";

    values = post(url,{initDate:initDate,endDate:endDate,num_of_days:dur_of_per,num_of_periods:num_of_per });

    if(! values)
        return;

    data.addColumn('string', 'Periodo');
    data.addColumn('number', 'Cantidad'); 

    var keys = Object.keys(values); 

    for(var i = 0; i < keys.length; i++ )
    {
      data.addRow([ keys[i] + " días.", values[keys[i]] ]);
    }

    drawPieGraph(data,'Tiempos de Entrega Requeridos');
}

function drawKPIkpiREByUser(initDate,endDate,userID)
{
    if(userID.length > 1)
      alert('Selecciona sólo un Comprador');

    var user = userID[0];
    var data = new google.visualization.DataTable();

    url = "/stadistic/kpiREByUser";

    values = post(url,{initDate:initDate,endDate:endDate,userID:user });

    if(! values)
        return;

    data.addColumn('string', 'Estado Partidas');
    data.addColumn('number', 'Cantidad'); 

    var keys = Object.keys(values); 
    var total = 0;

    for(var i = 0; i < keys.length; i++ )
    {
      if(!isNaN(values[keys[i]]))
      {
        data.addRow([ keys[i], values[keys[i]] ]);
        total += values[keys[i]];
      }
    }

    var title = 'Eficiencia de ' + values['name'] + " .Total " + total.toString() + " partidas.";
    drawPieGraph(data,title);

}

function drawPieGraph(data,title)
{
  var options = {'title':title,
                 'width':740,
                 'height':500,
                 'pieSliceText': 'value',
                 'is3D': false,
                 'pieHole': 0.4 };

  var chart = new google.visualization.PieChart(document.getElementById('kpi_chart_div'));
  chart.draw(data, options);

}