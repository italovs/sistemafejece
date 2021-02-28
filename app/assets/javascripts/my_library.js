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
	$("#post_link").hide();
	$("#post_category").hide();
	$("#post_name").hide();
	$("#post_description").hide();
	$("#create_new_post").hide();
}

function setting_events(){

	$("#new_post").on("click", function(){
		if(!$("#post_link").is(":visible")){
			hide_fields()
		}
		$("#post_link").toggle();
		$("#post_category").toggle();
		$("#post_name").toggle();
		$("#post_description").toggle();
		$("#create_new_post").toggle();
	})

	$("#create_new_post").on("click", function(){
		if( valid_value( $("#post_link").val() ) && valid_value( $("#post_category").val() ) && valid_value($("#post_name").val()) && valid_value($("#post_description").val()) ){
			$.post( '/new_post' ,
			{
				name: $("#post_name").val(),
				category: $("#post_category").val(),
				link: $("#post_link").val(),
				description: $("#post_description").val()
			},
			function(data, status){
				if(status == "success"){
					page_reload()
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		} else {
			alert("Há campos em branco")
		}
	})

	$("#new_serie").on("click", function(){
		// if(!$("#serie_name").is(":visible")){
		// 	hide_fields()
		// }
		// $("#serie_name").toggle();
		// $("#create_new_serie").toggle();
		// $("#tv_series_category").toggle();
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