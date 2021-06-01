//= require jquery
//= require rails-ujs
//= require turbolinks



$.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });


$(function(){
  $(".open-post").on("click", function(e){
    e.stopPropagation();
    
    $.post( '/update_views' ,
    { id: parseInt($(this).attr('id')) },
    function(data, status){
      if(status == "success"){
      } else {
      }
    })
  });

  $(".play-video").on("click", function(e){
    e.stopPropagation();
    console.log($(this).attr('id'))
    $.post( '/update_views' ,
    { id: parseInt($(this).attr('id')) },
    function(data, status){
      if(status == "success"){
      } else {
      }
    })
  });
})

function RequestError(data, xhr, reload=false){
  $(".err").html("código: " + data.status)
  if(data.responseJSON != 0){
    $(".err").append(" "+ data.responseJSON[0]["msg"]);
  }
  $(".notify.error-msg").css("display","none");
  $(".notify.error-msg").show();
  if (reload){
    setTimeout(function(){
      location.reload();
    }, 2000);
  }
  
}
function RequestSuccess(data, xhr, reload=false){
  $(".succes").html(data[0]["msg"]);
  $(".notify.success-msg").css("display","none");
  $(".notify.success-msg").show();
  if (reload){
    setTimeout(function(){
      location.reload();
    }, 2000);
  }
}


