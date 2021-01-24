//tabelas
function refill_table( table_id, dados, kind = "", columns = [] ){
	$( table_id ).empty()
	if ($(table_id+" tbody").length == 0) {
    $(table_id).append("<tbody></tbody>");
	}
	for(i = 0; i < dados.length; i++){
		line = create_line(dados[i], kind, columns)
		$( 'tbody', table_id).append(line)
	}

}

function create_line(dados, kind = "", columns = []){
	if(columns.length > 0){
		novos_dados = []
		novos_dados.push("")
		for(k = 0; k < columns.length; k++){
			novos_dados.push( dados[ columns[k] ] )
		}
		dados = novos_dados
	}
	line = "<tr><td>"+dados[1]+"</td><td>"+dados[2]+"</td>"
	console.log(kind)
	if(kind == "member"){
		line += '<td><div id="director_'+dados[0]+'" class="btn btn-primary">Tornar Diretor' 
		line += '</div></td><td><div id="member_'+dados[0]+'" class="btn btn-primary">Tornar Membro</div></td>';
	} else if(kind == "director") {
		line += '<td><div id="member_'+dados[0]+'" class="btn btn-primary">Tornar Membro</div></td>';
	}
	line += "</tr>"
	return line
}

//forms
function verify_same_data( data_1, data_2, field_name, errors_array){
	if( (data_1 != data_2) && ((data_1 != "") && (data_2 != "")) ){
		errors_array.push("Campos de "+field_name+" são diferentes!")
	} 
	return errors_array;
}

function collect_data( redundant_fields = [] ){
	fields = {};
	errors = []
	$(".input_field").each(function(){
		this_field = $(this).attr("name"); 
		fields[ this_field ] = $(this).val();
		if( fields[ this_field ] == "" ){
			if( this_field.indexOf("_2") != -1 ){
				invalid_field = "repetição de "+ this_field.substring(0, this_field.length - 2);
			} else {
				invalid_field = this_field
			}
			errors.push("Campo de "+invalid_field+" não pode estar em branco")
		}
	});
	if( errors.length > 0){
		for(j = 0; j < redundant_fields.length; j++){
			errors = verify_same_data( fields[redundant_fields[j]], fields[redundant_fields[i] +"_2"], redundant_fields[i], errors )
		}
	}
	if(errors.length == 0){
		return [true, fields]
	} else {
		return [false, errors]
	}
}

function clear_forms(){
	$(".input_field").each(function(){ 
		$(this).val("")
	});
}

function ajax_submit(fields, target_path, clear_fields = false, tables = [], columns = [] ){
	$.post( target_path ,
		{
			my_form_data: fields
		},
		function(data, status){
    if(status == "success"){
			if(clear_fields == true){
				clear_forms()
				if(tables.length > 0){
					for(i = 0; i < tables.length; i++){
						refill_table(tables[i], data[0]["ejs"], "", columns)
					}
				}
			}

			// console.log(data)
			// alert(data[0]["msg"])
    } else {
			//ERRO DE REQUISIÇÃO
		}
    
  });
}
