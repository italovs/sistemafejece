//= require jquery
//= require rails-ujs
//= require turbolinks




$.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });

function RequestError(data,statusCode, xhr){
  $(".error-msg").show();
  if(data.length != 0){
    $(".err").html(data[0]["msg"]);
  }else{
    $(".err").html(xhr.status);
    console.log(statusCode);
    console.log(xhr.responseText);
  }
}
function RequestSuccess(data, statusCode, xhr){
  $(".success-msg").show();
  $(".succes").html(data[0]["msg"]);
  //page_reload();  
}
