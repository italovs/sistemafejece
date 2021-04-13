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
    starting_from_videos();
    setting_events();
}

function page_reload(){
	starting_from_videos();
}

function starting_from_videos(){
	$(".videos-row").show();
	$(".posts-row").hide();
	$("#video").addClass("bg-secondary");
	$("#post").removeClass("bg-secondary");
	$("#video").removeClass("btn-f-green");
	$("#post").addClass("btn-f-green");
}

function setting_events(){
    $("#video").on("click", function(){
        $(".videos-row").show();
        $(".posts-row").hide();
        $("#video").addClass("bg-secondary");
        $("#post").removeClass("bg-secondary");
        $("#video").removeClass("btn-f-green");
        $("#post").addClass("btn-f-green");

    })

    $("#post").on("click", function(){
        $(".videos-row").hide();
        $(".posts-row").show();
        $("#post").addClass("bg-secondary");
        $("#video").removeClass("bg-secondary");
        $("#post").removeClass("btn-f-green");
        $("#video").addClass("btn-f-green");

    })

    $("#description-button").on("click", function(){
        
        if ($("#details-section").is(":visible")){
            $("#details-section")
                .css('opacity', 1)
                .animate(
                    { opacity: 0 },
                    { duration: 'slow' }
                )
                .delay(400)
                .hide('slow');     
        }else{
            $("#details-section")
                .css('opacity', 0)
                .slideDown('slow')
                .delay(400)
                .animate(
                    { opacity: 1 },
                    { duration: 'slow' }
                );
        }

        if ($("#serie_description").is(":visible")){
            $("#serie_description")
                .css('opacity', 1)
                .animate(
                    { opacity: 0 },
                    { duration: 'slow' }
                )
                .delay(400)
                .hide('slow');
        }else{
            $("#serie_description")
                .css('opacity', 0)
                .slideDown('slow')
                .animate(
                    { opacity: 1 },
                    { duration: 'slow' }
                );
        }
    })
}    