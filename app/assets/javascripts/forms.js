function verify_same_data( field_1, field_2, field_name){
  if( ($(field_1).val() != "") && ($(($(field_1).val() != ""))) &&  ($(field_1).val() != $(field_2).val())  ){
    return "Campos de "+field_name+" são diferentes!"
  }
}

function collect_data(){
  fields = {} //json
  $(".input_field").each(function(){
    fields[ $(this).attr("name") ] = $(this).val();
  });
  console.log(fields)
}

$(function(){
  $("#send").on("click", function(){
    collect_data();
  });
});

