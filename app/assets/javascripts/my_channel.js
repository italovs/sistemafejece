//= require jquery

$(function(){
	page_load();
})

function page_load(){
	hide_fields()
	setting_events()
	if( $("#tv_series  option").length > 1 ){
		$("#tv_series").trigger('change')
	}
	starting_from_videos();
	initial_create_table();
}

function page_reload(){
	hide_fields();
	starting_from_videos();
	initial_create_table();
}


function starting_from_videos(){
	$(".videos-row").show();
	$(".series-row").hide();
	$("#video").addClass("bg-secondary");
	$("#series").removeClass("bg-secondary");
	$("#video").removeClass("btn-f-green");
	$("#series").addClass("btn-f-green");
}

function initial_create_table(){
	$(".form-row").hide();
	$("#create_new_video").hide();
	$("#create_new_serie").hide();
}

function hide_fields(){
	$("#full-content").hide();
	$(".video-field").hide();
	$(".serie-field").hide();
	$("#youtube_link").hide();
	$("#serie_name").hide();
	$("#create_new_serie").hide();
	$("#create_new_video").hide();
	$("#tv_series").hide();
	$("#season").hide();
	$("#tv_series_category").hide();
	$("#youtube_name").hide();
	$("#youtube_description").hide();
	$("#my_series").hide()
}

function setting_events(){
	$("#series").on("click", function(){
		if( $("#my_series").is(":visible") ){
			//COMPLETAR
		}
	})

	$("#new_video").on("click", function(){
		if(!$("#youtube_link").is(":visible")){
			hide_fields()
		}

		$("#full-content").toggle();
		$("#main_title").text("Novo Vídeo");
		$(".video-field").toggle();
		$("#youtube_link").toggle();
		$("#create_new_video").toggle();
		$("#tv_series").toggle();
		$("#season").toggle();
		$("#youtube_name").toggle();
		$("#youtube_description").toggle();
	})

	$("#new_serie").on("click", function(){
		if(!$("#serie_name").is(":visible")){
			hide_fields()
		}

		$("#full-content").toggle();
		$("#main_title").text("Nova Série");
		$(".serie-field").toggle();
		$("#serie_name").toggle();
		$("#create_new_serie").toggle();
		$("#tv_series_category").toggle();
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
		if(valid_value($("#tv_series").val())){
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

	$("#create_new_video").on("click", function(){
		if(valid_value($("#youtube_link").val()) && valid_value($("#youtube_name").val()) && valid_value($("#youtube_description").val()) && valid_value($("#season").val()) ){
			link = sanitarize_youtube_link($("#youtube_link").val())
			if(link != null){
				var formData = new FormData();
				formData.append('name', $("#youtube_name").val())
				formData.append('video_link', link)
				formData.append('description', $("#youtube_description").val())
				formData.append('season', $("#season").val())
				formData.append('poster_image', $("#poster_image").prop('files')[0])
				formData.append('banner_image', $("#banner_image").prop('files')[0])
				$.ajax({
					url: '/new_video',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(){
					hide_fields()
				}).fail(function(){
					//ERRO DE REQUISIÇÃO
				});
			}
		}
	})

	$("#series").on("click", function(){
		hide_fields()
		$.post( '/my_series' ,
		{
		},
		function(data, status){
			if(status == "success" ){
				if(!data.hasOwnProperty("msg")){
					$("#my_series").show()
					insert_card_areas(data)
				} else {
					//erro
				}
			} else {
				//ERRO DE REQUISIÇÃO
				
			}
		})
	})

	$("#videos").on("click", function(){
		hide_fields()
		$.post( '/my_categories' ,
		{
		},
		function(data, status){
			if(status == "success" ){
				if(!data.hasOwnProperty("msg")){
					//$("#my_series").show()
					$("#my_series").show()
					insert_card_areas(data[0]["categories"])
				} else {
					//erro
				}
			} else {
				//ERRO DE REQUISIÇÃO
				
			}
		})
	})

	$("#video").on("click", function(){
		$(".videos-row").show();
		$(".series-row").hide();
		$("#video").addClass("bg-secondary");
		$("#series").removeClass("bg-secondary");
		$("#video").removeClass("btn-f-green");
		$("#series").addClass("btn-f-green");

	})

	$("#series").on("click", function(){
		$(".videos-row").hide();
		$(".series-row").show();
		$("#series").addClass("bg-secondary");
		$("#video").removeClass("bg-secondary");
		$("#series").removeClass("btn-f-green");
		$("#video").addClass("btn-f-green");

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

function video_embed( link, width = 1047, height = 558 ){
	return '<iframe width="' + width + '" height="' + height + '" src="https://www.youtube.com/embed/'+ link +'" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'
}

function sanitarize_youtube_link( link ){
	//embed
	if( link.indexOf("embed/") > 0){
		link = link.replace("embed/", "*")
		position = link.indexOf("*") + 1
		link = link.substring(position, link.length)
		position = link.indexOf('"')
		link = link.substring(0, position)
		if(link.length > 0){
			return link
		}
	}
	//normal
	if( link.indexOf("watch?v=") > 0){
		link = link.replace("watch?v=", "*")
		position = link.indexOf("*") + 1
		link = link.substring(position, link.length)
		if(link.length > 0){
			return link
		}
	}
	//mobile
	if( link.indexOf("youtu.be/") > 0){
		link = link.replace("youtu.be/", "*")
		position = link.indexOf("*") + 1
		link = link.substring(position, link.length)
		if(link.length > 0){
			return link
		}
	}
	alert("Link inválido!")
	return null
}

function new_card_area(name, data){
	html = 	"<h3>"+name+"</h3>"
	html += '<div id="'+name+'" class="card-group">'
	//inserindo cards
	$(data).each(function(index, element){
		html += '<div class="card">'
		html += 	'<div class="card-body">'
		html +=			'<h5 class="card-title">'+ element["name"] +'</h5>'
		html += 	'</div>'
		html += '</div>'
	})
	
	//fim dos cards
	html += "</div>"
	return html
}

function new_card_area2(name, data){
	html =	'<div class="card" id="category_'+ data[0]["id"] +'">'
  html +=		'<img class="card-img-top" src="..." alt="Card image cap">'
  html +=  	'<div class="card-body">'
  html +=   	'<h5 class="card-title">'+ name + '</h5>'
  html +=    	'<p class="card-text">Séries: '+ data[0]["quantity"]+'</p>'
	if(data[1] > 0){
		html +=		'<p class="card-text">Temporadas: '+ data[1] +'</p>'
		if(data[2] > 0){
			html +=	'<p class="card-text">Vídeos: '+ data[2] +'</p>'
		}
	}
  html +=  	'</div>'
  html +=	'</div>'
	//fim dos cards
	return html
}

function series_from_category(id){
	
}

function insert_events( full_id ){
	
}

function insert_card_areas(data){
	html = ""
	for (var key in data) {
		if (data.hasOwnProperty(key)) {
			if(data[key].length > 0){
				html += new_card_area2(key, data[key])
			}
    }
	}
	console.log(html)
	$("#my_series").html(html)
}