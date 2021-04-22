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
    initial_posts_list();
}

function page_reload(){
	starting_from_videos();
    initial_posts_list();
}

function starting_from_videos(){
	$(".videos-row").show();
	$(".posts-row").hide();
	$("#video").addClass("bg-secondary");
	$("#post").removeClass("bg-secondary");
	$("#video").removeClass("btn-f-green");
	$("#post").addClass("btn-f-green");
}

function is_video_not_evaluated(post, poster_image){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><img src='"+poster_image+
    "'><div class='play-btn'><a href='https://www.youtube.com/watch?v="+post["link"]+
    "' class='play-video'><i class='fas fa-play'></i></a></div></div><div class='stars'><div class='d-inline-flex'><h6 class='fas fa-star text-warning mr-2 pb-4'></h6><h6 class='text-white pt-1'>Não há avaliações</h6></div></div><div class='listing-content'><div class='inner'><h2 class='title'>"+post["name"]+
    "</h2><p>"+post["description"]+"</p><a class='btn btn-main btn-effect' href='/post/"+post["id"]+"'>Detalhes</a></div></div></div></div></div>")

}

function is_video_evaluated(post, poster_image, rating){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><img src='"+poster_image+
    "'><div class='play-btn'><a href='https://www.youtube.com/watch?v="+post["link"]+
    "' class='play-video'><i class='fas fa-play'></i></a></div></div><div class='stars'><input class='rating-input' type='hidden' value='"+rating+"' /><div class='rating pb-4'></div></div><div class='listing-content'><div class='inner'><h2 class='title'>"+post["name"]+
    "</h2><p>"+post["description"]+"</p><a class='btn btn-main btn-effect' href='/post/"+post["id"]+"'>Detalhes</a></div></div></div></div></div>")

}

function is_post_not_evaluated(post, poster_image){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><img src='"+poster_image+
    "'><div class='play-btn'><a href='https://www.youtube.com/watch?v="+post["link"]+
    "' class='play-video'><i class='fas fa-link'></i></a></div></div><div class='stars'><div class='d-inline-flex'><h6 class='fas fa-star text-warning mr-2 pb-4'></h6><h6 class='text-white pt-1'>Não há avaliações</h6></div></div><div class='listing-content'><div class='inner'><h2 class='title'>"+post["name"]+
    "</h2><p>"+post["description"]+"</p><a class='btn btn-main btn-effect' href='/post/"+post["id"]+"'>Detalhes</a></div></div></div></div></div>")

}

function is_post_evaluated(post, poster_image, rating){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><img src='"+poster_image+
    "'><div class='play-btn'><a href='https://www.youtube.com/watch?v="+post["link"]+
    "' class='play-video'><i class='fas fa-link'></i></a></div></div><div class='stars'><input class='rating-input' type='hidden' value='"+rating+"' /><div class='rating pb-4'></div></div><div class='listing-content'><div class='inner'><h2 class='title'>"+post["name"]+
    "</h2><p>"+post["description"]+"</p><a class='btn btn-main btn-effect' href='/post/"+post["id"]+"'>Detalhes</a></div></div></div></div></div>")

}

function is_post(season){
    $("#posts-list").append("<div class='col-md-12 col-sm-12 var-item p-0'><div class='movie-list-1 mb30'><div class='listing-container'><div class='listing-image'><div class='play-btn'><a href='<%= post.link %>' class='play-video'><i class='fas fa-link'></i></a></div><div class='buttons'><a href='#' data-original-title='Rate' data-toggle='tooltip' data-placement='bottom'><i class='fas fa-heart'></i></a><a href='#' data-original-title='Share' data-toggle='tooltip' data-placement='bottom'><i class='fas fa-share-alt'></i></a></div></div><div class='listing-content'><div class='inner'><h2 class='title'>"+nome+"</h2><p>"+descricao+"</p></div></div></div></div></div>")
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

        $.post( '/posts_from_season' ,
        {
            season_id: $(this).val()
        },
        function(data, status){
            if(status == "success" ){
                console.log(data[0]["rating"])

                $("#posts-list .var-item").remove();


                for (var i = 0; i < data[0]["posts"]["length"]; i++)
                {
                    if (data[0]["posts"][i]["kind"] == "video" && data[0]["rating"][i] == -1)
                    {
                        is_video_not_evaluated(data[0]["posts"][i], data[0]["poster_image"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "video" && data[0]["rating"][i] != -1)
                    {
                        is_video_evaluated(data[0]["posts"][i], data[0]["poster_image"][i], data[0]["rating"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "post" && data[0]["rating"][i] == -1)
                    {
                        is_post_not_evaluated(data[0]["posts"][i], data[0]["poster_image"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "post" && data[0]["rating"][i] != -1)
                    {
                        is_post_evaluated(data[0]["posts"][i], data[0]["poster_image"][i], data[0]["rating"][i]);
                    }
                }

                stars_evaluation();
            } else {
                //ERRO DE REQUISIÇÃO
            }
        })
    })
}

function initial_posts_list(){
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
                    if (data[0]["posts"][i]["kind"] == "video" && data[0]["rating"][i] == -1)
                    {
                        is_video_not_evaluated(data[0]["posts"][i], data[0]["poster_image"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "video" && data[0]["rating"][i] != -1)
                    {
                        is_video_evaluated(data[0]["posts"][i], data[0]["poster_image"][i], data[0]["rating"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "post" && data[0]["rating"][i] == -1)
                    {
                        is_post_not_evaluated(data[0]["posts"][i], data[0]["poster_image"][i]);
                    }
                    else if (data[0]["posts"][i]["kind"] == "post" && data[0]["rating"][i] != -1)
                    {
                        is_post_evaluated(data[0]["posts"][i], data[0]["poster_image"][i], data[0]["rating"][i]);
                    }
                }

                stars_evaluation();
            } else {
                //ERRO DE REQUISIÇÃO
            }
        })
}