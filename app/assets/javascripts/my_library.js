//= require selectize
var $select = $(".selectize").selectize({
	plugins: ['remove_button'],
	persist: false,
	maxItems: null,
	valueField: 'id',
	searchField: 'name'
  });
  var selectize = $select[0].selectize;

$(function(){
	page_load();
})

function page_load(){
	hide_fields();
	setting_events();
}

function page_reload(){
	hide_fields();
}

function hide_fields(){
	$("#full-content").hide();

}

function setting_events(){

	$("#new_post").on("click", function(){
		if(!$("#post_link").is(":visible")){
			hide_fields();
			$("#posts-row").hide();
		}
		$("#full-content").toggle();
		$("main").toggle();
		$("#update_post").hide();
		$("#create_new_post").show();

		if ($("main").is(":visible")){
            $(this).text("Novo Post");
        }
        else{
            $(this).text("Meus Posts");
        }
	})

	$("#create_new_post").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();

		if( valid_value( $("#post_link").val() ) && valid_value( $("#post_category").val() ) && valid_value($("#post_name").val()) && valid_value($("#post_description").val()) ){
			var formData = new FormData();
			formData.append('name',$("#post_name").val())
			formData.append('categories', $("#post_category").val())
			formData.append('link',$("#post_link").val())
			formData.append('description',$("#post_description").val())
			$("#poster_image").prop('files').length == 1 ? formData.append('poster_image',$("#poster_image").prop('files')[0]) : null
			$("#banner_image").prop('files').length == 1 ? formData.append('banner_image',$("#banner_image").prop('files')[0]) : null
			$.ajax({
				url:'/new_post',
				data: formData,
				type: 'POST',
				contentType:false,
				processData:false
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
			
			// $.post( '/new_post' ,
			// {
			// 	name: $("#post_name").val(),
			// 	category: $("#post_category").val(),
			// 	link: $("#post_link").val(),
			// 	description: $("#post_description").val()
			// },
			// function(data, status){
			// 	if(status == "success"){
			// 		page_reload()
			// 	} else {
			// 		//ERRO DE REQUISIÇÃO
					
			// 	}
			// })
		} else {
			alert("Há campos em branco")
		}
	})
	$(".edit_post").on("click", function(){
		$("#full-content").show();
		$("#main_title").text("Editar Post");
		$("#post_title").show();
		$("main").toggle();
		$("#update_post").show();
		$("#create_new_post").hide();
		$("#post_description").show();
		$("#posts-row").hide();
		

		var post_id = $(this).val();
		$("#update_input").val(post_id);
		var post_information;

		$.post('/post_information', 
		{
			id: post_id
		},function(data, status){
			if(status == "success"){
				post_information = data[0]
				$('#post_name').val(post_information["post_name"]);
				$('#post_link').val(post_information["post_link"]);
				$('#post_description').val(post_information["post_description"]);
				
				selectize.clear()
				categories = post_information["post_categories"]
				
				for (var i = 0 ; i < categories.length; i++)
				{
					selectize.addItem(categories[i]["id"]);
				}
				
			} else {
				//ERRO DE REQUISIÇÃO
			}
		})
	})
	$("#update_post").on("click", function(){
		$(".success-msg").hide();
		$(".error-msg").hide();
		
		
		var formData = new FormData();
		formData.append('post_id', $('#update_input').val())
		formData.append('name', $("#post_title").val())
		formData.append('link', $("#post_link").val())
		formData.append('description', $("#post_description").val())
		formData.append('categories', $("#post_category").val())
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
		}).fail(function(data){
			//ERRO DE REQUISIÇÃO
			//page_reload();
			$(".error-msg").show();
			$(".err").html(data[0]["msg"]);
		});
			
		
	})
	$(".delete_post").on("click",function(){
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

	$("#my_posts").on("click", function(){
		hide_fields();
		$("#posts-row").toggle();
		$.post( '/my_posts' ,
		{ },
		function(data, status){
			if(status == "success"){
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
	});

	$(".play-video").on("click", function(){
		$.post( '/update_views' ,
		{ id: $(this).attr('id') },
		function(data, status){
			if(status == "success"){
			} else {
			}
		})
	});

	$("#my_library_posts").DataTable({
		paging: true,
		ordering: false,
		language:{
			url: "/dataTable_portuguese.json"
		}
	})
}

function new_card_area(name, data){
	html = 	"<h3>"+name+"</h3>"
	html += '<div id="'+name+'" class="card-group">'
	//inserindo cards
	$(data).each(function(index, element){
		html += '<a href="/post/'+ element["pc_id"] + '">'
		html += 	'<div class="card">'
		html += 		'<img class="card-img-top" src="..." alt="Card image cap">'
		html += 		'<div class="card-body">'
		html +=      	'<h5 class="card-title">'+ element["name"] +'</h5>'
		html +=      	'<p class="card-text">'+ element["description"] +'</p>'
		if(element["votes"] == 0){
			html += 		'<p class="card-text"><small class="text-muted">Nota: 5</small></p>'
		} else {
			html += 		'<p class="card-text"><small class="text-muted">Nota: '+ (element["sum_votes"]/( element["votes"]).toFixed(2)) +'</small></p>'
		}
		html +=    	'</div>'
		html += 	'</div>'
		html += '</a>'
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
	$("#posts_area").html(html)
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