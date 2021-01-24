$(function(){
	$("div.btn.btn-primary").on("click", function(){
		fire_ajax(this)
	})
})

function fire_ajax( obj ){
  id = $(obj).attr("id");
  if( id.substring( 0, id.indexOf("_")) == "director" ){
    director = true;
  } else if( id.substring( 0, id.indexOf("_")) == "member" ){
    director = false;
  }
  member_id = id.substring( id.indexOf("_") + 1, id.length)
  $.post("/pirates/directors",
  {
    id: member_id,
    status: director
  },
  function(data, status){
    if(status == "success"){
      refill_table("#membros", data[0]["members"], "member")
      refill_table("#diretores", data[0]["directors"], "director")
    }
    $("div.btn.btn-primary").on("click", function(){
      fire_ajax(this)
    })
  });
}