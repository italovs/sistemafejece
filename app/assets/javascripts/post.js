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
	reset_fields();
}

function page_reload(){
	reset_fields();
}

function reset_fields(){
	$("#value").val(0);
}

function valid_value(value){
	if( typeof(value) !== "undefined" && value != null && value != "" ){
		return true;
	} else {
		return false;
	}
}


$(".button-evaluation").on("click", function(){
	
	var val = parseInt($(this).val());
	$(".button-evaluation").each(function(){
		
		$(this).removeClass("fas fa-star");
		// $(this).removeAttr('id', 'value')
		$(this).addClass("far fa-star");
		
		if (val >= parseInt($(this).val())){
			$(this).addClass("fas fa-star")
		}
	});

	// $(this).attr('id', 'value');
	$("#value").val(val);

});

$(".button-reset").on("click", function(){
	
	$(".button-evaluation").each(function(){
		$(this).removeClass("fas fa-star");
		// $(this).removeAttr('id', 'value')
		$(this).addClass("far fa-star");
	});

	$("#value").val(0);
})

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
