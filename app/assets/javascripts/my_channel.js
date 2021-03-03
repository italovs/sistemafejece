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
		if(valid_value($("#youtube_link").val()) && valid_value($("#youtube_name").val()) && valid_value($("#youtube_description").val()) && valid_value($("#tv_series").val()) && valid_value($("#season").val()) ){
			link = sanitarize_youtube_link($("#youtube_link").val())
			if(link != null){
				$.post( '/new_video' ,
				{
					video_link: link,
					name: $("#youtube_name").val(),
					description: $("#youtube_description").val(),
					tv_series: $("#tv_series").val(),
					season: $("#season").val()
				},
				function(data, status){
					if(status == "success" ){
						hide_fields()
						//refill_select_box( "#season", data[0]["seasons"] )
					} else {
						//ERRO DE REQUISIÇÃO
						
					}
				})
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
				console.log(data)
				if(!data.hasOwnProperty("msg")){
					$("#posts_area").show()
					insert_card_areas(data)
				} else {
					//erro
				}
			} else {
				//ERRO DE REQUISIÇÃO
				
			}
		})
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

function video_embed( link ){
	return '<iframe width="1047" height="558" src="https://www.youtube.com/embed/'+ link +'" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'
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
		html += 	'<img class="card-img-top" src="..." alt="Card image cap">'
		html += 	'<div class="card-body">'
		html +=			'<h5 class="card-title">'+ element["name"] +'</h5>'
		//html +=			video_embed( element["link"] )
		html += 		'<p class="card-text">'+ element["description"] +'</p>'
		if(element["votes"] == 0){
			//html += 	'<p class="card-text"><small class="text-muted">Nota: 5</small></p>'
		} else {
			//html += 	'<p class="card-text"><small class="text-muted" id="nota">'+ (element["sum_votes"]/( element["votes"]).toFixed(2)) +'</small></p>'
		}
		html += 	'</div>'
		html += '</div>'
	})
	
	//fim dos cards
	html += "</div>"
	return html
}

function insert_card_areas(data){
	html = ""
	for (var key in data) {
		if (data.hasOwnProperty(key)) {
			if(data[key].length > 0){
				html += new_card_area(key, data[key])
			}
    }
	}
	$("#my_series").html(html)
}