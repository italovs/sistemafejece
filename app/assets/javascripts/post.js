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

	if ($("#final-rating-input").val() > -1){
		final_evaluation();
	}else{
		$(".final-evaluation-form").hide();
	}
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

function final_evaluation(){
	var stars = $("#final-rating-input").val();
	console.log(stars)
	
	if (stars > -1){
		stars = Math.round(stars);
		var full_star = Math.floor(stars/2);
		var half_star = (stars % 2);
		var empty_star = 5 - (full_star + half_star);

		for(var i=1; i<= full_star; i++){
			$(".final-rating").append('<i class="fas fa-star text-warning px-2"></i>').show();
		}
		for(var i=1; i<= half_star; i++){
			$(".final-rating").append('<i class="fas fa-star-half-alt text-warning px-2"></i>').show();
		}
		for(var i=1; i<= empty_star; i++){
			$(".final-rating").append('<i class="far fa-star text-warning px-2"></i>').show();
		}
	}	

		//$(".evaluation-form").hide();
		//$("final-evaluation-form").show();
}

function change_evaluation_elements(){
	$(".evaluation-form .title").text("Sua avaliação foi:");
	$("#create_new_vote").hide();
	$(".make-evaluation .fa-undo").hide();
	$(".make-evaluation .fa-star").each(function(){
		var input = this
		input.disabled = true;
	})
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
					final_evaluation();
					change_evaluation_elements();
					//location.reload();
					//refill_select_box( "#value", data[0]["value"] )
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		} else {
			alert("Há campos em branco")
		}
	})

	$(".play-video").on("click", function(){
		$.post( '/update_views' ,
		{ id: $(this).attr('id') },
		function(data, status){
			if(status == "success"){
			} else {
			}
		})
	});
}
