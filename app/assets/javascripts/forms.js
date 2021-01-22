function verify_same_data( field_1, field_2){
  if( ($(field_1).val() != "") && ($(($(field_1).val() != "")))    ($(field_1).val() != $(field_2).val())  ){
    alert("Valores diferentes!")
  }
}

function collect_data(){
  fields = {} //json
  
  
  $(input).each(function(){
    fields[ $(this).attr("name") ] = $(this).val();
  });
}