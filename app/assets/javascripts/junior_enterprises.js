$(function(){
	$("#send").on("click", function(){
		response = collect_data();
		if( response[0] == true ){
			ajax_submit(response[1], "/pirates/junior_enterprises", true, ["#junior_enterprises"], ["name", "description"])			
		} else {
			// alert(response[1])
			//EXIBIR ERROS NA TELA
		}
	});

	$(".remove_junior_enterprise").on("click", function(){
		$.post( '/pirates/junior_enterprises/remove' ,
		{
			id: $(this).attr('id').replace("junior_enterprise_","") 
		},
		function(data, status){
			if(status == "success"){
				console.log(data[0]["ejs"])
				//refill_table(["#junior_enterprises"], data[0]["ejs"], "", ["name", "description"])
				$( "#junior_enterprises" ).empty()
				if ($("#junior_enterprises"+" tbody").length == 0) {
					$("#junior_enterprises").append('<tbody id="membros_t"></tbody>');
				}
				for(i = 0; i < data[0]["ejs"]; i++){
					line = create_line(dados[i], kind, columns)
					$( 'tbody', "#junior_enterprises").append(line)
				}
			} else {
				//ERRO DE REQUISIÇÃO

			}
		});
	})


});