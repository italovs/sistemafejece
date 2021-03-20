//tabelas
function refill_table( table_id, dados, kind = "", columns = [] ){
	$( table_id ).empty()
	if ($(table_id+" thead").length == 0) {
		$(table_id).append('<thead class="bg-light"></thead>');
	}
	$('thead', table_id).append( '<tr><th scope="col" class="border-0">#</th><th scope="col" class="border-0">Nome</th><th scope="col" class="border-0">EJ</th><th scope="col" class="border-0">Ações</th></tr>' )
	if ($(table_id+" tbody").length == 0) {
    $(table_id).append('<tbody id="'+ table_id.substring(1, table_id.length) +'_t"></tbody>');
	}
	for(i = 0; i < dados.length; i++){
		line = create_line(i+1, dados[i], kind, columns)
		$( 'tbody', table_id).append(line)
	}
}

function create_line(contador, dados, kind = "", columns = []){
	if(columns.length > 0){
		novos_dados = []
		novos_dados.push("")
		for(k = 0; k < columns.length; k++){
			novos_dados.push( dados[ columns[k] ] )
		}
		dados = novos_dados
	}
	line = "<tr><td>"+ contador +"</td><td>"+dados[1]+"</td><td>"+dados[2]+"</td>"
	if(kind == "member"){
		line += '<td><i id="director_'+dados[0]+'" class="btn btn-success material-icons become_director" title="Tornar diretor">check</i>'
		line += '&nbsp;'
		line += '<i id="member_'+dados[0]+'" class="btn btn-danger material-icons become_member" title="Tornar membro">close</i></td>'
	} else if(kind == "director") {
		line += '<td><i id="member_'+dados[0]+'" class="btn btn-danger material-icons become_member" title="Tornar membro">close</i></td>'
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
		console.log(data)
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
