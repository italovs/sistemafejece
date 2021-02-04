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

	initial_buttons()

	$("#director").on("click", function(){
		im_a_director()
	})

	$("#edit").on("click", function(){
		change_information()
	})

	$("#change_password").on("click", function(){
		change_password()
	});

	
	reset_fields()
});

function im_a_director(){
	$.post( '/request_to_become_a_director' ,
		{
			email: $("#member_email").val() 
		},
		function(data, status){
		if(status == "success"){
			reset_fields()
			update_data(data[0])
			$("#director").hide()
		} else {
			//ERRO DE REQUISIÇÃO
			reset_fields()
		}
	});
}

function change_information(){
	$("#field").show();
	$("#profile_info").hide();
	$(".profile_data").show()
	$("#password").show()
}

function reset_fields(){
	$("#field").show();
	$("#profile_info").show();
	$(".profile_data").hide()
	$(".password").hide()
}

function change_password(){
	if($("#change_password").html() == "NOVA SENHA"){
		$(".field").hide();
		$("#profile_info").hide();
		$(".profile_data").hide()
		$(".password").show()
		$("#change_password").html("ENVIAR")
	} else {
		$.post( '/change_password' ,
		{
			old_password: $("#old_password").val(),
			new_password: $("#change_password").val(),
			confirmation_password: $("#confirmation_password").val() 
		},
		function(data, status){
			if(status == "success"){
				reset_fields()
				console.log(data[0])
				//update_data(data[0])
			} else {
				//ERRO DE REQUISIÇÃO
				reset_fields()
			}
		});
		
		$("#change_password").html("NOVA SENHA")
	}
}

function update_data( new_data ){
	$('#name').html(new_data["member"]["name"] || "Não informado")
	$('#about').html(new_data["member"]["about"] || "Não informado")
	$('#about').html(new_data["member"]["position"] || "Não informado")
	$('#email').html(new_data["member"]["email"])
	$('#junior_enterprise').html(new_data["junior_enterprise"])
	if( new_data["member"]["validated"] == "true" ){
		$("#validated").html("Membro Diretor")
	} else if( new_data["member"]["validated"] == "false" ){
		$("#validated").html("Membro")
	} else {
		$("#validated").html("Diretoria Solicitada")
	}
}

function initial_buttons(){
	$("#change_password").html("NOVA SENHA");
}
