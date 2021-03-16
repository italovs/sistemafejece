//= require jquery
$(document).on("turbolinks:load",function(){
	$(".selectize").selectize();
});

$.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });

$(function(){
	page_load();
	
})

function page_load(){
	setting_events();
}

function page_reload(){
	
}


function setting_events(){

	$("#create_new_vote").on("click", function(){
		if(valid_value($("#post_id").val()) && valid_value($("#value").val()) ){
			$.post( '/new_vote' ,
			{
                post_id: $("#post_id").val(),
				value: $("#value").val()
			},
			function(data, status){
				if(status == "success"){
					page_reload()
					refill_select_box( "#value", data[0]["value"] )
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		} else {
			alert("Há campos em branco")
		}
	})

}