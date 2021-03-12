//= require jquery
//= require selectize
//= require rails-ujs

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
    initial_paginate();
  }  


// $(".paginate-item").on("click", function(){
// 	var this_value = $(this).val();
// 	var maxRows = 2;
// 	var min = (this_value-1)*maxRows + 1;
// 	var max = (this_value-1)*maxRows + maxRows;
// 	var trnum = 0;
// 	$('.var-item').each(function(){
// 		trnum++;
		
// 		$(this).hide();
// 		if (trnum <= max && trnum >= min ){
// 			$(this).show();
// 		}
	
// 	})
// 	$('.paginate-item').removeClass('bg-f-green');
// 	$('.paginate-item').removeClass('text-white');
//     $(this).addClass('bg-f-green');
// 	$(this).addClass('text-white');
	
// })

function initial_paginate(){
	var this_value = 1;
	var maxRows = 2;
	var min = (this_value-1)*maxRows + 1;
	var max = (this_value-1)*maxRows + maxRows;
	console.log(this_value);
	console.log(min);
	console.log(max);
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
  $(' .paginate-item:first').addClass('bg-f-green');
	$(' .paginate-item:first').addClass('text-white');
}