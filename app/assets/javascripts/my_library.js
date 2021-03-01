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
	$("#post_link").hide();
	$("#post_category").hide();
	$("#post_name").hide();
	$("#post_description").hide();
	$("#create_new_post").hide();
	$("#posts_area").hide()
}

function setting_events(){

	$("#new_post").on("click", function(){
		if(!$("#post_link").is(":visible")){
			hide_fields()
		}
		$("#post_link").toggle();
		$("#post_category").toggle();
		$("#post_name").toggle();
		$("#post_description").toggle();
		$("#create_new_post").toggle();
	})

	$("#create_new_post").on("click", function(){
		if( valid_value( $("#post_link").val() ) && valid_value( $("#post_category").val() ) && valid_value($("#post_name").val()) && valid_value($("#post_description").val()) ){
			$.post( '/new_post' ,
			{
				name: $("#post_name").val(),
				category: $("#post_category").val(),
				link: $("#post_link").val(),
				description: $("#post_description").val()
			},
			function(data, status){
				if(status == "success"){
					page_reload()
				} else {
					//ERRO DE REQUISIÇÃO
					
				}
			})
		} else {
			alert("Há campos em branco")
		}
	})

	$("#my_posts").on("click", function(){
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
}

function new_card_area(name, data){
	html = 	"<h3>"+name+"</h3>"
	html += '<div id="'+name+'" class="card-group">'
	//inserindo cards
	$(data).each(function(index, element){
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