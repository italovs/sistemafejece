//= require selectize
$(".selectize").selectize({
	plugins: ['remove_button'],
	persist: false,
	maxItems: null,
	valueField: 'id',
	searchField: 'name'
  });

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
	})

	$("#create_new_post").on("click", function(){
		if( valid_value( $("#post_link").val() ) && valid_value( $("#post_category").val() ) && valid_value($("#post_name").val()) && valid_value($("#post_description").val()) ){
			var formData = new FormData();
			formData.append('name',$("#post_name").val())
			formData.append('categories', $("#post_category").val())
			formData.append('link',$("#post_link").val())
			formData.append('description',$("#post_description").val())
			formData.append('poster_image',$("#poster_image").prop('files')[0])
			formData.append('banner_image',$("#banner_image").prop('files')[0])
			$.ajax({
				url:'/new_post',
				data: formData,
				type: 'POST',
				contentType:false,
				processData:false
			}).done(function(){
				page_reload()
			}).fail(function(){
				//ERRO DE REQUISIÇÃO
			})
			
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
	$(".delete_video").on("click",function(){
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