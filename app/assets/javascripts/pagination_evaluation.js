//= require jquery

$(".paginate-item").on("click", function(){
	var this_value = $(this).val();
	var maxRows = 2;
	var min = (this_value-1)*maxRows + 1;
	var max = (this_value-1)*maxRows + maxRows;
	var trnum = 0;
	$('.var-item').each(function(){
		trnum++;
		
		$(this).hide();
		if (trnum <= max && trnum >= min ){
			$(this).show();
		}
	
	})
	$('.paginate-item').removeClass('bg-f-green');
	$('.paginate-item').removeClass('text-white');
    $(this).addClass('bg-f-green');
	$(this).addClass('text-white');
	
})


function initial_paginate(){
	var this_value = 1;
	var maxRows = 2;
	var min = (this_value-1)*maxRows + 1;
	var max = (this_value-1)*maxRows + maxRows;
	var trnum = 0;
	$('.var-item').each(function(){
		trnum++;
		
		$(this).hide();
		if (trnum <= max && trnum >= min ){
			$(this).show();
		}
	
	})
	$('.paginate-item').removeClass('bg-f-green');
	$('.paginate-item').removeClass('text-white');
	$('.paginate-item:first').addClass('bg-f-green');
	$('.paginate-item:first').addClass('text-white');
}



$(".paginate-item-2").on("click", function(){
	var this_value = $(this).val();
	var maxRows = 2;
	var min = (this_value-1)*maxRows + 1;
	var max = (this_value-1)*maxRows + maxRows;
	var trnum = 0;
	$('.var-item-2').each(function(){
		trnum++;
		
		$(this).hide();
		if (trnum <= max && trnum >= min ){
			$(this).show();
		}
	
	})
	$('.paginate-item-2').removeClass('bg-f-green');
	$('.paginate-item-2').removeClass('text-white');
    $(this).addClass('bg-f-green');
	$(this).addClass('text-white');
	
})


function initial_paginate_2(){
	var this_value = 1;
	var maxRows = 2;
	var min = (this_value-1)*maxRows + 1;
	var max = (this_value-1)*maxRows + maxRows;
	var trnum = 0;
	$('.var-item-2').each(function(){
		trnum++;
		
		$(this).hide();
		if (trnum <= max && trnum >= min ){
			$(this).show();
		}
	
	})
	$('.paginate-item-2').removeClass('bg-f-green');
	$('.paginate-item-2').removeClass('text-white');
	$('.paginate-item-2:first').addClass('bg-f-green');
	$('.paginate-item-2:first').addClass('text-white');
}

function stars_evaluation(){
	var j = 0;
	$(".rating-input").each(function(){
		var star = $(this).val();
		star = Math.round(star);
		var full_star = Math.floor(star/2);
		var half_star = (star % 2);
		var empty_star = 5 - (full_star + half_star);

		for(var i=1; i<= full_star; i++){
			$(".rating").eq(j).append('<i class="fas fa-star"></i>').show();
		}
		for(var i=1; i<= half_star; i++){
			$(".rating").eq(j).append('<i class="fas fa-star-half-alt"></i>').show();
		}
		for(var i=1; i<= empty_star; i++){
			$(".rating").eq(j).append('<i class="far fa-star"></i>').show();
		}
		j++;
	})	


}