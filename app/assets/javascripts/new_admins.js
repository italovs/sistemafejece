//= require jquery

$(function(){
	$("#send").on("click", function(){

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
		}).done(function(data, statusCode, xhr){
			RequestSuccess(data, statusCode, xhr);
			
		}). fail(function(data, statusCode, xhr){
			RequestError(data, statusCode, xhr);
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
	}).done(function(data, statusCode, xhr){
		RequestSuccess(data, statusCode, xhr);
		
	}). fail(function(data, statusCode, xhr){
		RequestError(data, statusCode, xhr);
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

});


