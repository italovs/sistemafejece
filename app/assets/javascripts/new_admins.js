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
});

$(".remove_admin").click(function(){
	$.post( '/pirates/remove_pirate',
		{
			id: $(this).attr('id').replace("admin_","") 
		},
		function(data, status){
			if(status == "success"){
				//Colocar notificação
				console.log(data[0])
			} else {
				//ERRO DE REQUISIÇÃO

			}
		});
})


