$(function(){
	page_load();
})

function page_load(){
	hide_fields()
	setting_events()
}

function page_reload(){
	hide_fields()
}

function hide_fields(){
	$("#youtube_link").hide();
	$("#serie_name").hide();
	$("#create_new_serie").hide();
	$("#create_new_video").hide();
	$("#tv_series").hide();
	$("#season").hide();
	$("#tv_series_category").hide();
}

function setting_events(){
	$("#new_video").on("click", function(){
		hide_fields()
		$("#youtube_link").show();
		$("#create_new_video").show();
		$("#tv_series").show();
		$("#season").show();
	})

	$("#new_serie").on("click", function(){
		hide_fields()
		$("#serie_name").show();
		$("#create_new_serie").show();
		$("#tv_series_category").show();
	})

	$("#create_new_serie").on("click", function(){
		if( valid_value($("#serie_name").val()) && valid_value($("#tv_series_category").val()) ){
			$.post( '/new_serie' ,
			{
				serie_name: $("#serie_name").val(),
				category: $("#tv_series_category").val() 
			},
			function(data, status){
				if(status == "success"){
					page_reload()
					refill_select_box( "#tv_series", data[0]["tv_series"] )
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		} else {
			alert("Há campos em branco")
		}
	})

	$("#tv_series").on("change", function(){
		valid_value($("#tv_series").val()){
			$.post( '/serie_seasons' ,
			{
				serie: $("#tv_series").val()
			},
			function(data, status){
				if(status == "success" && (data[0]["seasons"].length > 0) ){
					refill_select_box( "#season", data[0]["seasons"] )
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		}
	})
}



function refill_select_box( target, data ){
	$(target).empty()
	$(target).append(new Option("Selecione", ""))
	$(data).each(function(index, element){
		$(target).append(new Option( element["name"], element["id"]))
	})
	$(target).val("")
}

function valid_value(value){
	if( typeof(value) !== "undefined" && value != null && value != "" ){
		return true;
	} else {
		return false;
	}
}