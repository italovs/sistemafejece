//= require jquery
//= require selectize
//$(document).on("turbolinks:load",function(){
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
					console.log(data[0]['post_image']);
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

		$("#form-fields").toggle();
		$("#series_list_wrapper").toggle();
		$("#seasons").hide();
		$("#update_serie").hide();
        
	})

    $(".edit_serie").on("click", function(){
		if(!$("#serie_name").is(":visible")){
			hide_fields()
		}

		$("#form-fields").toggle();
		$("#series_list_wrapper").toggle();
        if ($("#series_list_wrapper").is(":visible")){
            $(this).text("Nova Série");
        }
        else{
            $(this).text("Minhas Séries");
        }
		$("#seasons").show();

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
					selectize_posts.addItem(posts_first_season[i]["id"]);
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
			
		});

	})

	$("#season-select").on('change', function(){
		season = "season" + $(this).val();
		posts = $("#seasons_post").val();
		sessionStorage.setItem(season,posts);

		selectize_posts.clear()
		formData = new FormData
		formData.append('season_id', $('option:selected',this).data('value'))
		$.ajax({
			url: '/season',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data){
			posts = data[0]["posts"]
			for (var i =0; i< posts.length; i++){
				selectize_posts.addItem(posts[i]["id"]);
			}
		})

	})



    $(".delete_serie").on("click", function(){
        var serie_id = $(this).data('value')
        var confirmation = confirm("Tem certeza que quer deletar essa Trilha?")
        formData = new FormData

        formData.append('id', serie_id)
        if(confirmation == true){
            $.ajax({
                url: '/delete_serie',
                data: formData,
                type: 'POST',
                contentType: false,
                processData: false
            }).done(function(data){
                //page_reload();
                $(".success-msg").show();
                $(".succes").html(data[0]["msg"]);
            }).fail(function(data){
                //ERRO DE REQUISIÇÃO
                //page_reload();
                console.log(data)
                $(".error-msg").show();
                $(".err").html(data[0]["msg"]);
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
			}).done(function(data){
				//page_reload();
				$(".success-msg").show();
				$(".succes").html(data[0]["msg"]);
			}).fail(function(data){
				//ERRO DE REQUISIÇÃO
				//page_reload();
				console.log(data)
				$(".error-msg").show();
				$(".err").html(data[0]["msg"]);
			});

		}else {
			alert("Há campos em branco")
		}
	})

	$("#update_serie").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();

		if( valid_value($("#serie_name").val()) && valid_value($("#tv_series_category").val()) && valid_value($("#serie_description").val())){
				var formData = new FormData();
				console.log("entrou===============")
				formData.append('tv_serie_id', $('#update_input').val())
				formData.append('name', $("#serie_name").val())
				formData.append('description', $("#serie_description").val())
				formData.append('categories', $("#tv_series_category").val())
				$("#serie_poster_image").prop('files').length == 1 ? formData.append('poster_image', $("#serie_poster_image").prop('files')[0]) : null
				$("#serie_banner_image").prop('files').length == 1 ? formData.append('banner_image', $("#serie_banner_image").prop('files')[0]) : null
			$.ajax({
				url: '/update_serie',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			}).done(function(data){
				//page_reload();
				$(".success-msg").show();
				$(".succes").html(data[0]["msg"]);
			}).fail(function(data){
				//ERRO DE REQUISIÇÃO
				//page_reload();
				console.log(data)
				$(".error-msg").show();
				$(".err").html(data[0]["msg"]);
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