//= require jquery

$(function(){
	$("#send").on("click", function(){
		
		formData = new FormData
		formData.append('name', $("#name").val())
		formData.append('description',$("#description").val());
		$.ajax({
			url: '/pirates/categories',
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