//= require jquery
//= require rails-ujs
//= require turbolinks




$.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });

function RequestError(data,statusCode, xhr){
  $(".err").html("código: " + data.status)
  if(data.responseJSON != 0){
    $(".err").append(" "+ data.responseJSON[0]["msg"]);
  }
  $(".notify.error-msg").css("display","none");
  $(".notify.error-msg").show();
  
}
function RequestSuccess(data, statusCode, xhr){
  $(".succes").html(data[0]["msg"]);
  $(".notify.success-msg").css("display","none");
  $(".notify.success-msg").show();
  //page_reload();  
}
