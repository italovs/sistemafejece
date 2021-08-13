//= require jquery
//= require assets/jqueryui
//= require selectize



//$(document).on("turbolinks:load",function(){
	var flag_verify_posts_selectize_ready = false;
	var $select = $("#tv_series_category").selectize({
		plugins: ['remove_button'],
		persist: false,
		maxItems: null,
		valueField: 'id',
		searchField: 'name'
	});
	var selectize = $select[0].selectize;

	var $select_posts = $("#seasons_post").selectize({
		plugins: ['remove_button'],
		plugins: ['remove_button','drag_drop'],
		persist: false,
		maxItems: null,
		valueField: 'id',
		searchField: 'text',
		render: {	
			item: function(item, escape) {
				var poster_image ;
				formData = new FormData;
				formData.append('id',item.id);
				$.ajax({
					async: false,
					url: '/post_information',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(data){
					poster_image = data[0]['post_image']
				})
				return "<div><img src=" + poster_image + " style='width:30px;' class='flag flag-" + item.id + "' alt='flag' />&nbsp;" + item.text + "</div>";
			},
			option: function(item, escape) {
				var poster_image ;
				formData = new FormData;
				formData.append('id',item.id);
				$.ajax({
					async:false,
					url: '/post_information',
					data: formData,
					type: 'POST',
					contentType: false,
					processData: false
				}).done(function(data){
					poster_image = data[0]['post_image']
				})
				return "<div><img src=" + poster_image + " style='width:30px;' class='flag flag-" + item.id + "' alt='flag' />&nbsp;" + item.text + "</div>";
			}
		},
		onChange: function(){
			if (flag_verify_posts_selectize_ready == true){
				selected_season = "season"+$("#season-select").val()
				sessionStorage.setItem(selected_season, $("#seasons_post").val())
			}
		}
	});
	var selectize_posts = $select_posts[0].selectize;



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
}

function page_reload(){
	hide_fields();
}


function hide_fields(){
	$("#form-fields").hide();
}

function setting_events(){
	$(".selectize-input").eq(1).css("display", "grid");

	$("#series").on("click", function(){
		if( $("#my_series").is(":visible") ){
			//COMPLETAR
		}
	})

	$("#new_serie").on("click", function(){
		if(!$("#serie_name").is(":visible")){
			hide_fields()
		}
		$("#create_new_serie").show()
		$("#form-fields").toggle();
		$("#series_list_wrapper").toggle();
		$("#seasons").hide();
		$("#update_serie").hide();
        
	})

    $(".edit_serie").on("click", function(){
		flag_verify_posts_selectize_ready = false;
		if(!$("#serie_name").is(":visible")){
			hide_fields()
		}
		
		sessionStorage.clear();
		$("#form-fields").toggle();
		$("#series_list_wrapper").toggle();
        if ($("#series_list_wrapper").is(":visible")){
            $(this).text("Nova Série");
        }
        else{
            $(this).text("Minhas Séries");
        }
		$("#seasons").show();
		$("#create_new_serie").hide()

		var tv_serie_id = $(this).val();
		$("#update_input").val(tv_serie_id);
		var tv_serie_information;

		$.post('/serie_information', 
		{
			id: tv_serie_id
		},function(data, status){
			if(status == "success"){
				tv_serie_information = data[0]
				$('#serie_name').val(tv_serie_information["tv_serie_name"]);
				$('#serie_description').val(tv_serie_information["tv_serie_description"]);
				
				selectize.clear()
				selectize_posts.clear()
				categories = tv_serie_information["tv_serie_categories"]
				posts_first_season = tv_serie_information["first_season_posts"]
				
				for (var i = 0 ; i < categories.length; i++)
				{
					selectize.addItem(categories[i]["id"]);
				}
				
				for (var i =0; i< posts_first_season.length; i++){
					selectize_posts.addItem(posts_first_season[i]["post_id"]);
				}
				
				tv_serie_information["tv_serie_seasons"].forEach(function(season){
					var option = document.createElement("option");
					option.setAttribute("value", season.order);
					option.setAttribute("data-value", season.id);
					var text_option = document.createTextNode(season.order + "ª temporada")
					option.appendChild(text_option);
					$("#season-select").append(option)
				})
	
			} else {
				//ERRO DE REQUISIÇÃO
			}
			flag_verify_posts_selectize_ready = true;
		});

	})
	$("#season-select").on('mousedown',function(){ 
		sessionStorage.setItem('previous',$("#season-select").val());
	});
	$("#new_season").on('click',function(){
		formData = new FormData
		formData.append('id', $('#update_input').val())
		$.ajax({
			url: '/new_season',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data, xhr) {
			RequestSuccess(data, xhr, false);
			var option = document.createElement("option");
			option.setAttribute("value", data[0]['new_season_order']);
			option.setAttribute("data-value", data[0]['new_season_id']);
			var text_option = document.createTextNode(data[0]['new_season_order'] + "ª temporada")
			option.appendChild(text_option);
			$("#season-select").append(option)
			
		}).fail(function(data, xhr){
			RequestError(data, xhr, false);
		});
		
	})

	$("#delete-season").on('click', function() {
		selected_season = $("#season-select").val();
		var confirmation = confirm("Tem certeza que quer deletar a " + selected_season + "ª temporada?");
		if (confirmation){
			flag_verify_posts_selectize_ready = false;
			formData = new FormData
			formData.append('season_id', $("#season-select :selected").data('value'))

			$.ajax({
				url: '/delete_season',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			})
			.done(function(data, xhr){
				RequestSuccess(data, xhr, false);
				$.post('/serie_information', {
						id: $("#update_input").val()
					},
					function(data, status){
						if(status == "success"){
							tv_serie_information = data[0]
							posts_first_season = tv_serie_information["first_season_posts"]

							selectize_posts.clear()
							$("#season-select").empty();

							tv_serie_information["tv_serie_seasons"].forEach(function(season){
								var option = document.createElement("option");
								option.setAttribute("value", season.order);
								option.setAttribute("data-value", season.id);
								var text_option = document.createTextNode(season.order + "ª temporada")
								option.appendChild(text_option);
								$("#season-select").append(option)
							});

							for (var i =0; i< posts_first_season.length; i++){
								selectize_posts.addItem(posts_first_season[i]["post_id"]);
							}
							sessionStorage.clear()
						}
					}
				);

			}).fail(function(data, xhr){
				RequestError(data, xhr, false);
			});
			flag_verify_posts_selectize_ready = true;
		}
	});
	$("#season-select").on('change', function(){
		flag_verify_posts_selectize_ready = false;
		season_before_change = sessionStorage.getItem('previous');
		season_to_storage = "season" + season_before_change;
		posts = $("#seasons_post").val();
		sessionStorage.setItem(season_to_storage,posts);

		actual_season = "season" + $("#season-select").val();

		selectize_posts.clear();
		formData = new FormData;
		formData.append('season_id', $('option:selected',this).data('value'));
		var posts_id = sessionStorage.getItem(actual_season);

		if (posts_id == null){
			$.ajax({
				async: false,
				url: '/season',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			}).done(function(data){
				posts  = data[0]["posts"];
				posts_id = [];
				for (var i = 0; i<posts.length; i++){
					posts_id.push(posts[i]["post_id"]);
				}
			});
		}else{
			posts_id = posts_id.split(',').map(function (item) {
				return parseInt(item)
			})
		}

		if(posts_id.length == 0){
			selectize_posts.clear();
		}else{
			for (var i =0; i< posts_id.length; i++){
				selectize_posts.addItem(posts_id[i]);
			}
		}
		season_to_storage = "season" + $(this).val();
		posts = $("#seasons_post").val();
		sessionStorage.setItem(season_to_storage,posts);
		flag_verify_posts_selectize_ready = true;
	})

	


    $(".delete_serie").on("click", function(){
        var serie_id = $(this).val();
        var confirmation = confirm("Tem certeza que quer deletar essa Trilha?");
        formData = new FormData;

        formData.append('id', serie_id);
        if(confirmation == true){
            $.ajax({
                url: '/delete_serie',
                data: formData,
                type: 'POST',
                contentType: false,
                processData: false
            }).done(function(data, xhr){
				RequestSuccess(data, xhr, true);
            }).fail(function(data, xhr){
                RequestError(data, xhr, false);
            });
        }

    });

	$("#create_new_serie").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();

		if( valid_value($("#serie_name").val()) && valid_value($("#tv_series_category").val()) && valid_value($("#serie_description").val())){
			var formData = new FormData();
				formData.append('serie_name', $("#serie_name").val())
				formData.append('serie_description', $("#serie_description").val())
				formData.append('categories', $("#tv_series_category").val())
				$("#serie_poster_image").prop('files').length == 1 ? formData.append('poster_image', $("#serie_poster_image").prop('files')[0]) : null
				$("#serie_banner_image").prop('files').length == 1 ? formData.append('banner_image', $("#serie_banner_image").prop('files')[0]) : null
			$.ajax({
				url: '/new_serie',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			}).done(function(data, xhr){
				RequestSuccess(data, xhr, true);
			}).fail(function(data, xhr){
				RequestError(data, xhr, false);
			});

		}else {
			alert("Há campos em branco")
		}
	})

	$("#update_serie").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();
		var seasons_and_posts = {};
		$("#season-select option").each(function(){
			season = "season" + $(this).val();
			if(sessionStorage.getItem(season) != null){
				seasons_and_posts["" + $(this).attr('data-value')] = sessionStorage.getItem(season);
				sessionStorage.removeItem(season);
			}
		})
		
		if( valid_value($("#serie_name").val()) && valid_value($("#tv_series_category").val()) && valid_value($("#serie_description").val())){
				var formData = new FormData();
				formData.append('tv_serie_id', $('#update_input').val());
				formData.append('name', $("#serie_name").val());
				formData.append('description', $("#serie_description").val());
				formData.append('categories', $("#tv_series_category").val());
				formData.append('seasons_and_posts', JSON.stringify(seasons_and_posts));
				
				$("#serie_poster_image").prop('files').length == 1 ? formData.append('poster_image', $("#serie_poster_image").prop('files')[0]) : null;
				$("#serie_banner_image").prop('files').length == 1 ? formData.append('banner_image', $("#serie_banner_image").prop('files')[0]) : null;
			$.ajax({
				url: '/update_serie',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			}).done(function(data, xhr){
				RequestSuccess(data, xhr, true);
			}).fail(function(data, xhr){
				RequestError(data, xhr, false)
			});

		}else {
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

	$("#series_list").DataTable({
		paging: true,
		ordering: false,
		language:{
			url: "/dataTable_portuguese.json"
		}
	})
}

//Characters counter
$("#serie_name").on("keyup", function(){
    var length = $(this).val().length;

    $("#title-count").html(length+"/60");
});

$("#serie_description").on("keyup", function(){
    var length = $(this).val().length;

    $("#description-count").html(length+"/350");
});

// JS DE TESTE
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
			} else {
				//erro
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

function passing_variable(data){
	var image = data[0]['post_image']
	return image;
}