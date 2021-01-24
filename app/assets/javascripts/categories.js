$(function(){
	$("#send").on("click", function(){
		response = collect_data();
		if( response[0] == true ){
			ajax_submit(response[1], "/pirates/junior_enterprises", true, ["#categories"], ["name", "description"])			
		} else {
			// alert(response[1])
			//EXIBIR ERROS NA TELA
		}
	});
});