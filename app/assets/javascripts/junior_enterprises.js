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
		ajax_action( this )
	})


});

function ajax_action( obj ){
	$.post( '/pirates/junior_enterprises/remove' ,
		{
			id: $(obj).attr('id').replace("junior_enterprise_","") 
		},
		function(data, status){
			if(status == "success"){
				if( data[0].hasOwnProperty("ejs") ){
					//refill_table(["#junior_enterprises"], data[0]["ejs"], "", ["name", "description"])
					$( "#junior_enterprises" ).empty()
					if ($("#junior_enterprises"+" tbody").length == 0) {
						$("#junior_enterprises").append('<tbody id="membros_t"></tbody>');
					}
					for(i = 0; i < data[0]["ejs"].length; i++){
						
						line = create_line(i+1, data[0]["ejs"][i]["name"], data[0]["ejs"][i]["description"], data[0]["ejs"][i]["id"])
						$( 'tbody', "#junior_enterprises").append(line)
					}
					$(".remove_junior_enterprise").on("click", function(){
						ajax_action( this )
					})
				}
			} else {
				//ERRO DE REQUISIÇÃO

			}
		});
}

function create_line(count, name, description, id){
	line = "<tr>"
	line += "<td>"+count+"</td>"
	line +=	"<td>"+name+"</td>"
	line += "<td>"+description+"</td>"
	line += create_button(id)
	line += "</tr>"
	return line
}

function create_button(id){
	return '<td><i id="junior_enterprise_'+ id +'" class="btn btn-danger material-icons remove_junior_enterprise" title="Remover EJ">close</i></td>'
}