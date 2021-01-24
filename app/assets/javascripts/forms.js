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
		for(i = 0; i < redundant_fields.length; i++){
			errors = verify_same_data( fields[redundant_fields[i]], fields[redundant_fields[i] +"_2"], redundant_fields[i], errors )
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

function ajax_submit(fields, target_path, clear_fields = false){
	$.post( target_path ,
  {
    my_form_data: fields
  },
  function(data, status){
    if(status == "success"){
			if(clear_fields == true){
				clear_forms()
			}
			// console.log(data)
			// alert(data[0]["msg"])
    } else {
			//ERRO DE REQUISIÇÃO
		}
    
  });
}