//= require jquery
//= require selectize
//$(document).on("turbolinks:load",function(){
	var $select = $(".selectize").selectize({
		plugins: ['remove_button'],
		persist: false,
		maxItems: null,
		valueField: 'id',
		searchField: 'name'
	});
	var selectize = $select[0].selectize;

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
}

function page_reload(){
	hide_fields();
}

function hide_fields(){
	$("#form-fields").hide();
	$(".success-msg").hide();
	$(".error-msg").hide();
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

	$("#new_video").on("click", function(){
		if(!$("#youtube_link").is(":visible")){
			hide_fields()
			console.log('click')
		}
		$("#form-fields").toggle();
		$("#main_title").text("Novo Vídeo");
		$(".video-field").show();
		$("#youtube_link").show();
		$("#create_new_video").show();
		$("#tv_series").hide();
		$("#season").hide();
		$("#youtube_name").show();
		$("#youtube_description").show();
		$(".videos-row").toggle();
		$(".series-row").hide();
		$("#youtube_name").val('')
		$("#youtube_link").val('')
		$("#youtube_description").val('')
	})

	$(".edit_video").on("click", function(){
		if(!$("#youtube_link").is(":visible")){
			hide_fields()
			console.log('click')
		}
		$("#form-fields").toggle();
		$("#main_title").text("Editar Vídeo");
		$(".video-field").show();
		$("#youtube_link").show();
		$("#update_video").show();
		$("#tv_series").hide();
		$("#season").hide();
		$("#youtube_name").show();
		$("#youtube_description").show();
		$(".videos-row").toggle();
		$(".series-row").hide();

		var post_id = $(this).val();
		$("#update_input").val(post_id);
		var post_information;

		$.post('/post_information', 
		{
			id: post_id
		},function(data, status){
			if(status == "success"){
				post_information = data[0]
				$('#youtube_name').val(post_information["post_name"]);
				$('#youtube_link').val("https://www.youtube.com/watch?v="+post_information["post_link"]);
				$('#youtube_description').val(post_information["post_description"]);
				
				selectize.clear()
				categories = post_information["post_categories"]
				
				for (var i = 0 ; i < categories.length; i++)
				{
					selectize.addItem(categories[i]["id"]);
				}
				
			} else {
				//ERRO DE REQUISIÇÃO
			}
			
		});

	})

	$(".delete_video").on("click",function(){
		$(".success-msg").hide();
		$(".error-msg").hide();
		
		var post_id = $(this).val()
		var confirmation = confirm("Tem certeza que quer deletar essa publicação?")

		if (confirmation == true){
			$.post('/delete_post',
			{
				id: post_id
			},function(data, status){
				if(status == "success"){
					//page_reload();
					$(".success-msg").show();
					$(".succes").html(data[0]["msg"]);
				}else{
					$(".error-msg").show();
					$(".err").html(data[0]["msg"]);
				}
			})
		}
	})

	$("#update_video").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();
		
		if(valid_value($("#youtube_link").val()) && valid_value($("#youtube_name").val()) && valid_value($("#youtube_description").val())  ){
			link = sanitarize_youtube_link($("#youtube_link").val())
			if(link != null){
				var formData = new FormData();
				formData.append('post_id', $('#update_input').val())
				formData.append('name', $("#youtube_name").val())
				formData.append('link', link)
				formData.append('description', $("#youtube_description").val())
				formData.append('categories', $("#category").val())
				$("#poster_image").prop('files').length == 1 ? formData.append('poster_image', $("#poster_image").prop('files')[0]) : null
				$("#banner_image").prop('files').length == 1 ? formData.append('banner_image', $("#banner_image").prop('files')[0]) : null
				$.ajax({
					url: '/update_post',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(data){
					//page_reload();
					$(".success-msg").show();
					$(".succes").html(data[0]["msg"]);
					console.log(data)
				}).fail(function(){
					//ERRO DE REQUISIÇÃO
					//page_reload();
					$(".error-msg").show();
					$(".err").html(data[0]["msg"]);
				});
			}
		}
	})	

	$("#create_new_video").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();
		
		if(valid_value($("#youtube_link").val()) && valid_value($("#youtube_name").val()) && valid_value($("#youtube_description").val())  ){
			link = sanitarize_youtube_link($("#youtube_link").val())
			if(link != null){
				var formData = new FormData();
				formData.append('name', $("#youtube_name").val())
				formData.append('video_link', link)
				formData.append('description', $("#youtube_description").val())
				formData.append('categories', $("#category").val())
				formData.append('poster_image',$("#poster_image").prop('files')[0])
				formData.append('banner_image',$("#banner_image").prop('files')[0])
				$.ajax({
					url: '/new_video',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(data){
					//page_reload();
					$(".success-msg").show();
					$(".succes").html(data[0]["msg"]);
					console.log(data)
				}).fail(function(data){
					//ERRO DE REQUISIÇÃO
					//page_reload();
					$(".error-msg").show();
					$(".err").html(data[0]["msg"]);
				});
			}
		} else {
			alert("Há campos em branco")
		}
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

	$("#my_channel_videos").DataTable({
		paging: true,
		ordering: false,
		language:{
			url: "/dataTable_portuguese.json"
		}
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