//= require jquery


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

	$("#change_information").on("click", function(){
		change_information()
	})

	$("#change_password").on("click", function(){
		change_password()
	});

	$("#change_mail").on("click", function(){
		change_mail()
	});

	reset_fields()
});

function im_a_director(){
	formData = new FormData
	formData.append('email',$("#member_email").val())
	$.ajax({
		url: '/request_to_become_a_director',
		data: formData,
		type: 'POST',
		contentType: false,
		processData: false
	}).done(function(data, xhr){
		RequestSuccess(data, xhr, false);
		reset_fields();
		update_data(data[0]);
		$("#director").hide();
	}). fail(function(data,  xhr){
		RequestError(data, xhr, false);
		reset_fields();
		
	})
}

function reset_fields(){
	$(".field").show();
	$("#profile_info").show();
	$(".profile_data").hide();
	$(".profile_picture").hide();
	$(".password").hide();
	$(".initial_table").show()
	$("#main_title").html("Detalhes do Perfil");
}

function change_mail(){
	if($("#change_mail").html() == "MUDAR E-MAIL"){
		initial_buttons()
		$(".initial_table").hide();
		$("#main_title").html("Atualizar E-mail");
		$(".field").hide();
		$("#profile_info").hide();
		$(".profile_data").hide();
		$(".email").show();
		$(".password").first().show();
		$("#change_mail").html("ENVIAR");
	} else {
		formData = new FormData
		formData.append('new_email',$("#new_email").val());
		formData.append('repeat_email', $("#repeat_email").val());
		formData.append('confirmation_password',$("#old_password").val());
		$.ajax({
			url: '/change_mail',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data, xhr){
			RequestSuccess(data, xhr, false);
			reset_fields();
		}). fail(function(data, xhr){
			RequestError(data, xhr, false);
			reset_fields();
		});
		
		$("#change_mail").html("MUDAR E-MAIL")
	}
}

function change_information(){
	if($("#change_information").html() == "ATUALIZAR DADOS"){
		initial_buttons()
		$(".initial_table").hide();
		$("#main_title").html("Atualizar Informações");
		$(".field").hide();
		$("#profile_info").hide();
		$(".profile_data").show();
		$(".email").hide();
		$(".profile_picture").show();
		$(".password").first().show();
		$("#change_information").html("ENVIAR")
	} else {
		//ajax (rota, parâmetros, função )
		var formData = new FormData();
		formData.append('name',$("#name_field").val())
		formData.append('about',$("#about_field").val())
		formData.append('junior_enterprise',$("#member_junior_enterprise_id").val())
		formData.append('position',$("#position_field").val())
		formData.append('confirmation_password',$("#old_password").val())
		formData.append('profile_picture',$("input[type=file]").prop('files')[0])
		$.ajax({
			url: '/change_information',
			data: formData,
			type: 'POST',
			contentType: false,
			processData:false,
		}).done(function( data, xhr ){
			reset_fields()
			RequestSuccess(data, xhr, true)
			update_data(data[0])
		}).fail(function(data, xhr){
			RequestError(data, xhr, false)
			reset_fields()
		});
		$("#change_information").html("ATUALIZAR DADOS")
		

		
	}
}


function change_password(){
	if($("#change_password").html() == "NOVA SENHA"){
		initial_buttons()
		$(".initial_table").hide();
		$("#main_title").html("Mudar Senha");
		$(".field").hide();
		$("#profile_info").hide();
		$(".profile_data").hide()
		$(".password").show()
		$("#change_password").html("ENVIAR")
	} else {
		formData = new FormData
		formData.append('old_password',$("#old_password").val());
		formData.append('new_password',$("#new_password").val());
		formData.append('confirmation_password',$("#confirmation_password").val());
		$.ajax({
			url: '/change_password',
			data: formData,
			type: 'POST',
			contentType: false,
			processData: false
		}).done(function(data,xhr){
			RequestSuccess(data, xhr, false);
			reset_fields();
		}). fail(function(data, xhr){
			RequestError(data, xhr, false);
			reset_fields();
		})
		
		$("#change_password").html("NOVA SENHA")
	}
}

function initial_buttons(){
	$("#change_password").html("NOVA SENHA");
	$("#change_mail").html("MUDAR E-MAIL");
	$("#change_information").html("ATUALIZAR DADOS");
}

//retorno de ajax
function update_data( new_data ){
	elemento_do_json = ""
	if(new_data.hasOwnProperty("member")  ){
		elemento_do_json = "member"
	} else {
		elemento_do_json = "person"
	}
	$('.name').html(new_data[elemento_do_json]["name"] || "Não informado")
	$('.about').html(new_data[elemento_do_json]["about"] || "Não informado")
	$('.position').html(new_data[elemento_do_json]["position"] || "Não informado")
	$('#email').html(new_data[elemento_do_json]["email"])
	$('#junior_enterprise').html(new_data["junior_enterprise"])
	if( new_data[elemento_do_json]["validated"] == "true" ){
		$("#validated").html("Membro Diretor")
	} else if( new_data[elemento_do_json]["validated"] == "false" ){
		$("#validated").html("Membro")
	} else {
		$("#validated").html("Diretoria Solicitada")
	}
}


//Navbar
//var menu_toggler = $("#mobile-nav-toggler");
//var menu_API = main_menu.data( "mmenu" );

//menu_toggler.on( "click", function() {
//	menu_API.open();
//	document.getElementById("mobile-nav-toggler").style.margin = "0px 450px 0px 0px";
//	$(".logo-white").hide();
//});

//var menuClose = $(".mm-slideout");

//menuClose.on("click", function(){
//	document.getElementById("mobile-nav-toggler").style.margin = "0px 0px 0px 0px";
//	$(".logo-white").show();
//});
//End of Navbar