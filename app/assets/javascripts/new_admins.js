//= require jquery

$(function(){
	$(".send").on("click", function(){

		formData = new FormData
		formData.append('name', $("#name").val())
		formData.append('email',$("#email").val());
		formData.append('password', $("#password").val());
		$.ajax({
			url: '/pirates/new_pirates',
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
});

$(".remove_admin").on("click",function(){
	formData = new FormData
	formData.append('id', $(this).attr('id').replace("admin_",""))
	$.ajax({
		url: '/pirates/remove_pirate',
		data: formData,
		type: 'POST',
		contentType: false,
		processData: false
	}).done(function(data, xhr){
		RequestSuccess(data, xhr, true);
		
	}). fail(function(data, xhr){
		RequestError(data, xhr, false);
	});
	
})

$(".edit_admin").on("click", function(){
	$("#admin-list").hide()
	$(".main-title").html('Editar Pirata');
	$("#name").show()
	$("#email").show();
	$("#password").show();
	$("#password_2").hide();
	$("#email_2").hide();
	$(".new-pirate").hide();
	$(".update").attr('id', $(this).attr('id'))
	$(".send").hide();
	$(".update").show();
	formData = new FormData
	formData.append('id', $(this).attr('id'))
	$.ajax({
		url: '/pirates/admin_info',
		type: 'POST',
		data: formData,
		processData: false,
		contentType: false,
		success: function(data){
			$("#name").val(data[0]["admin_name"]);
			$("#email").val(data[0]["admin_email"]);
		},
		error: function(data, xhr){
			RequestError(data, xhr, false);
		}
	});
});

$(".update").on('click',function(){
	formData = new FormData
	formData.append('id', $(this).attr('id'));
	formData.append('name', $("#name").val());
	formData.append('email', $("#email").val());
	formData.append('password', $("#password").val());
	$.ajax({
		url: '/pirates/admin_update',
		type: 'POST',
		data: formData,
		processData: false,
		contentType: false,
		success: function(data, xhr){
			RequestSuccess(data, xhr, true);
		},
		error: function(data, xhr){
			RequestError(data, xhr, false);
		}
	});
});


