$(function(){
  hide_fields()
  setting_events()
})

function hide_fields(){
  $("#youtube_link").hide();
  $("#serie_name").hide();
}

function setting_events(){
  $("#new_video").on("click", function(){
    $("#youtube_link").show();
  })

  $("#new_serie").on("click", function(){
    $("#serie_name").show();
  })
}