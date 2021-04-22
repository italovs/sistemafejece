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
    posts_list();
}

function page_reload(){
	starting_from_videos();
    posts_list();
}

function starting_from_videos(){
	$(".videos-row").show();
	$(".posts-row").hide();
	$("#video").addClass("bg-secondary");
	$("#post").removeClass("bg-secondary");
	$("#video").removeClass("btn-f-green");
	$("#post").addClass("btn-f-green");
}

function post_from_list(post, poster_image, rating, i){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><img src='"+poster_image+
    "'><div class='play-btn'></div></div><div class='stars'></div><div class='listing-content'><div class='inner'><h2 class='title'>"+post["name"]+
    "</h2><p>"+post["description"]+"</p><a class='btn btn-main btn-effect' href='/post/"+post["id"]+"'>Detalhes</a></div></div></div></div></div>")

    if (post["kind"] == "video")
    {
        $(".play-btn").eq(i).append("<a href='https://www.youtube.com/watch?v="+post["link"]+"' class='play-video'><i class='fas fa-play'></i></a>")
    }
    else if (post["kind"] == "post")
    {
        $(".play-btn").eq(i).append("<a href='"+post["link"]+"' class='play-video'><i class='fas fa-link'></i></a>")
    }

    if (rating == -1)
    {
        $(".stars").eq(i).append("<div class='d-inline-flex'><h6 class='fas fa-star text-warning mr-2 pb-4'></h6><h6 class='text-white pt-1'>Não há avaliações</h6></div>")
    }
    else
    {
        $(".stars").eq(i).append("<input class='rating-input' type='hidden' value='"+rating+"' /><div class='rating pb-4'></div>")
    }
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

    $("#seasons_select").on("change", function(){
        posts_list();
    })
}

function posts_list(){
    $.post( '/posts_from_season' ,
        {
            season_id: $("#seasons_select").val()
        },
        function(data, status){
            if(status == "success" ){
                console.log(data[0]["rating"])

                $("#posts-list .var-item").remove();


                for (var i = 0; i < data[0]["posts"]["length"]; i++)
                {
                    post_from_list(data[0]["posts"][i], data[0]["poster_image"][i], data[0]["rating"][i], i);
                }

                stars_evaluation();
            } else {
                //ERRO DE REQUISIÇÃO
            }
        })
}