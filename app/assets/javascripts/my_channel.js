//= require jquery
//= require selectize
//$(document).on("turbolinks:load",function(){
	$(".selectize").selectize({
		plugins: ['remove_button'],
		persist: false,
		maxItems: null,
		valueField: 'id',
		searchField: 'name'
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
	hide_fields();
	setting_events()
	if( $("#tv_series  option").length > 1 ){
		$("#tv_series").trigger('change')
	}
	starting_from_videos();
	initial_create_table();
	pagination();
}

function page_reload(){
	hide_fields();
	starting_from_videos();
	initial_create_table();
}

var table = "#mytable";
$("#maxRows").on('change', pagination)

function pagination(){
	$('.pagination').html('')
	var trnum = 0;
	var maxRows = parseInt($('#maxRows').val());
	var totalRows = $(table+'  tbody tr').length

	$(table+' tr:gt(0)').each(function(){
		trnum++;
		if(trnum > maxRows){
			$(this).hide();
		}
		if (trnum <= maxRows){
			$(this).show();
		}
	})

	if(totalRows > maxRows){
		var pagenum = Math.ceil(totalRows/maxRows)
		for(var i=1; i<=pagenum; ){
			$('.pagination').append('<li data-page="'+i+'" class="page-item">\<a class="page-link">' + i++ +'<a class="sr-only">(current)</a></a>\</li>').show();
		}
	}
	$('.pagination li:first-child').addClass('active')
	$('.pagination li').on('click', function(){
		var pageNum = $(this).attr('data-page');
		var trIndex = 0;
		$('.pagination li').removeClass('active')
		$(this).addClass('active')
		$(table+' tr:gt(0)').each(function(){
			trIndex++;
			if(trIndex > (maxRows*pageNum) || trIndex <= ((maxRows*pageNum)-maxRows)){
				$(this).hide();
			}else{
				$(this).show();
			}
		})
	})
}

$(function(){
	$('table tr:eq(0)').prepend('<th>ID</th>')
	var id = 0;
	$('table tr:gt(0)').each(function(){
		id++
		$(this).prepend('<td>'+id+'</td>')
	})
})

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
	$("#form-fields").hide();
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
	$("#my_series").hide();
	$("#full-content").hide();
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

	$("#series").on("click", function(){
		if( $("#my_series").is(":visible") ){
			//COMPLETAR
		}
	})

	$("#new_video").on("click", function(){
		if(!$("#youtube_link").is(":visible")){
			hide_fields()
			console.log('click')
		}
		$("#form-fields").show();
		$("#main_title").text("Novo Vídeo");
		$(".video-field").show();
		$("#youtube_link").show();
		$("#create_new_video").show();
		$("#tv_series").hide();
		$("#season").hide();
		$("#youtube_name").show();
		$("#youtube_description").show();
		$(".videos-row").hide();
		$(".series-row").hide();
	})

	$("#new_serie").on("click", function(){
		if(!$("#serie_name").is(":visible")){
			hide_fields()
		}

		$("#form-fields").show();
		$("#main_title").text("Nova Série");
		$(".serie-field").show();
		$("#serie_name").show();
		$("#create_new_serie").show();
		$(".videos-row").hide();
		$(".video-field").hide();
		$(".series-row").hide();
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
		if(valid_value($("#youtube_link").val()) && valid_value($("#youtube_name").val()) && valid_value($("#youtube_description").val())  ){
			link = sanitarize_youtube_link($("#youtube_link").val())
			if(link != null){
				var formData = new FormData();
				formData.append('name', $("#youtube_name").val())
				formData.append('video_link', link)
				formData.append('description', $("#youtube_description").val())
				formData.append('categories', $("#category").val())
				$("#poster_image").prop('files').length == 1 ? formData.append('poster_image', $("#poster_image").prop('files')[0]) : null
				$("#banner_image").prop('files').length == 1 ? formData.append('banner_image', $("#banner_image").prop('files')[0]) : null
				$.ajax({
					url: '/new_video',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(data){
					location.reload();
				}).fail(function(){
					//ERRO DE REQUISIÇÃO
				});
			}
		}
	})

	$("#series").on("click", function(){
		hide_fields();
		$.post( '/my_series' ,
		{
		},
		function(data, status){
			if(status == "success" ){
				if(!data[0].hasOwnProperty("msg")){
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
				if(!data[0].hasOwnProperty("msg")){
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
		$("#form-fields").hide();
		$("#video").addClass("bg-secondary");
		$("#series").removeClass("bg-secondary");
		$("#video").removeClass("btn-f-green");
		$("#series").addClass("btn-f-green");
	})

	$("#series").on("click", function(){
		$(".videos-row").hide();
		$(".series-row").show();
		$("#form-fields").hide();
		$("#series").addClass("bg-secondary");
		$("#video").removeClass("bg-secondary");
		$("#series").removeClass("btn-f-green");
		$("#video").addClass("btn-f-green");
	})
}

// JS DE TESTE
function search_for_video( category_id, owner_id, season_id, serie_id, name ){
	$.post( '/search_for_video' ,
	{
		category_id: category_id,
		owner_id: owner_id,
		season_id: season_id,
		serie_id: serie_id,
		name: name
	},
	function(data, status){
		if(status == "success" ){
			if(!data[0].hasOwnProperty("msg")){
				console.log(data)
			} else {
				//erro
				console.log(data[0]["msg"])
			}
		} else {
			//ERRO DE REQUISIÇÃO
		}
	})
}

function search_for_post( category_id, owner_id, name ){
	$.post( '/search_for_post' ,
	{
		category_id: category_id,
		owner_id: owner_id,
		name: name
	},
	function(data, status){
		if(status == "success" ){
			if(!data[0].hasOwnProperty("msg")){
				console.log(data)
			} else {
				//erro
				console.log(data[0]["msg"])
			}
		} else {
			//ERRO DE REQUISIÇÃO
		}
	})
}

function my_series_by_category( category_id ){
	$.post( '/my_series_by_category' ,
	{
		category_id: category_id
	},
	function(data, status){
		if(status == "success" ){
			if(!data[0].hasOwnProperty("msg")){
				console.log(data)
			} else {
				//erro
			}
		} else {
			//ERRO DE REQUISIÇÃO
		}
	})
}

function my_seasons_by_serie( serie_id ){
	$.post( '/my_seasons_by_serie' ,
	{
		serie_id: serie_id
	},
	function(data, status){
		if(status == "success" ){
			if(!data[0].hasOwnProperty("msg")){
				console.log(data)
			} else {
				//erro
			}
		} else {
			//ERRO DE REQUISIÇÃO
		}
	})
}
// FIM JS DE TESTE

//JS em uso
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
	$("#my_series").html(html)
}