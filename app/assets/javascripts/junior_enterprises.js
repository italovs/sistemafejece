//= require jquery


$(document).ready(function () {
	$('#junior_enterprises').DataTable({
		"paging":true,
		language:{
			url: "/dataTable_portuguese.json"
		},
		"initComplete": function(){
			 var rowToolbar = $("#junior_enterprises_wrapper").children('.row:first-child').css({
				"position": "relative",
				"text-align": "center",
				"margin-top": "-45px",
				"justify-content": "end",
				"width": "100%",
				"color": "white"
			});
			var quantityofItens = rowToolbar.children('div')[0];
			var searchField = rowToolbar.children('div')[1];
			searchField.style.marginLeft = "auto";
			searchField.style.marginRight = "5%";
			searchField.style.width = "20%";
			quantityofItens.style.marginLeft = "50%";
			quantityofItens.style.width = "20%";
			
		},
		"columnDefs": [{
			"type": "html-num", "targets":0
		}]
	});
	
}); 
$(function(){
	$("#send").on("click", function(){
		formData = new FormData
		formData.append('name', $('#name').val());
		formData.append('description', $('#description').val());
		$.ajax({
			url: '/pirates/junior_enterprises',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data, xhr){
			RequestSuccess(data, xhr, true);
			
		}). fail(function(data, xhr){
			RequestError(data, xhr, false);
		});
	});

	$(".remove_junior_enterprise").on("click", function(){
		var confirmation = confirm("Tem certeza que quer deletar essa empresa junior?");
		if (confirmation){
			ajax_action( this );
		}	
	})

	$(".editar_junior_enterprise").on("click", function(){
		formData = new FormData
		formData.append('id', $(this).attr('id'))
		$(".update").attr('id', $(this).attr('id'))
		$.ajax({
			url: '/pirates/junior_enterprise_info',
			data: formData,
			type: 'POST',
			processData: false,
			contentType: false,
			success: function(data, xhr){
				$("#ej-list").hide();
				$("#main-title").html('Editar Empresa Junior')
				$("#new-ej").hide();
				$("#name").val(data[0]["ej_name"])
				$("#decription").val(data[0]["ej_description"])
				$("#send").hide()
				
				$(".update").show();
			},
			error: function(data, xhr){
				RequestError(data, xhr, false);
			}
		})
	})
	$(".update").on('click',function(){
		formData = new FormData
		formData.append('id', $(this).attr('id'));
		formData.append('name', $("#name").val());
		formData.append('description', $("#description").val());
		$.ajax({
			url: '/pirates/update_junior_enterprise',
			data: formData,
			type: 'POST',
			processData: false,
			contentType: false,
			success: function(data, xhr){
				RequestSuccess(data, xhr, true);
			},
			error: function(data, xhr){
				RequestError(data, xhr, true);
			}
		})
	})

});



function ajax_action( obj ){
	formData = new FormData
	formData.append('id', $(obj).attr('id').replace("junior_enterprise_",""));
	$.ajax({
		url: '/pirates/junior_enterprises/remove',
		data: formData,
		type: 'POST',
		contentType: false,
		processData: false
	}).done(function(data, xhr){
		RequestSuccess(data, xhr, true);
		if( data[0].hasOwnProperty("ejs") ){
			//refill_table(["#junior_enterprises"], data[0]["ejs"], "", ["name", "description"])
			$( "#junior_enterprises" ).empty()
			if ($("#junior_enterprises"+" tbody").length == 0) {
				$("#junior_enterprises").append('<tbody id="membros_t"></tbody>');
			}
			for(i = 0; i < data[0]["ejs"].length; i++){
				
				line = create_line(i+1, data[0]["ejs"][i]["name"], data[0]["ejs"][i]["description"], data[0]["ejs"][i]["id"])
				$( 'tbody', "#junior_enterprises").append(line)
			}
			$(".remove_junior_enterprise").on("click", function(){
				ajax_action( this )
			})
		}
		
	}). fail(function(data, xhr){
		RequestError(data, xhr, false);
	});
	
}

function create_line(count, name, description, id){
	line = "<tr>"
	line += "<td>"+count+"</td>"
	line +=	"<td>"+name+"</td>"
	line += "<td>"+description+"</td>"
	line += create_button(id)
	line += "</tr>"
	return line
}

function create_button(id){
	return '<td><i id="junior_enterprise_'+ id +'" class="btn btn-danger material-icons remove_junior_enterprise" title="Remover EJ">close</i></td>'
}