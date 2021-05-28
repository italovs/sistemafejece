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
		}).done(function(data,  xhr){
			RequestSuccess(data, xhr, true);
			
		}). fail(function(data, xhr){
			RequestError(data, xhr, false);
		});
	});

	$(".remove_category").on('click', function(){
		formData = new FormData
		formData.append('id', $(this).attr('id'))
		var confirmation = confirm("Tem certeza que quer deletar essa categoria?")
		if (confirmation){
			$.ajax({
				url: '/pirates/remove_category',
				data: formData,
				type: 'POST',
				contentType: false,
				processData: false
			}).done(function(data,  xhr){
				RequestSuccess(data, xhr, true);
				
			}). fail(function(data, xhr){
				RequestError(data, xhr, false);
			});
		}
	})

	$(".edit_category").on('click',function(){
		
		formData = new FormData
		formData.append('id', $(this).attr('id'));
		$(".update").attr('id', $(this).attr('id'));
		$.ajax({
			url: '/pirates/category_info',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false,
			success: function(data, xhr){
				$("#category-list").hide();
				$("#main-title").html('Editar Categoria');
				$("#new-category").hide();
				$("#send").hide();
				$(".update").show();
				$("#name").val(data[0]["category_name"]);
				$("#description").val(data[0]["catefory_description"]);				
			},
			error: function(data, xhr){
				RequestError(data, xhr, false)
			}
		})
	});

	$(".update").on('click', function(){
		formData = new FormData
		formData.append('id', $(this).attr('id'));
		formData.append('name', $("#name").val());
		formData.append('description', $("#description").val())
		$.ajax({
			url: '/pirates/update_category',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data,  xhr){
			RequestSuccess(data, xhr, true);
			
		}). fail(function(data, xhr){
			RequestError(data, xhr, false);
		});
	});
	
});