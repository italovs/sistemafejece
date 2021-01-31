$(function(){
	$("#send").on("click", function(){
		response = collect_data([ "email", "senha" ]);
		if( response[0] == true ){
			ajax_submit(response[1], "/pirates/new_pirates", true)
		} else {
			// alert(response[1])
			//EXIBIR ERROS NA TELA
		}
	});

	$("#director").on("click", function(){
		im_a_director()
	})

	$("#edit").on("click", function(){
		change_information()
	})

	reset_fields()
});

function im_a_director(){
	//requisição
	alert("requisição")
}

function change_information(){
	$("#profile_info").hide();
	$(".profile_data").show()
	$("#password").show()
}

function reset_fields(){
	$("#profile_info").show();
	$(".profile_data").hide()
	$(".password").hide()
}

