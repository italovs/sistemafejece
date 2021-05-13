//= require jquery

$("#accept_informations").change(function() {
    if(this.checked) {
      $("#submit-button-1").show();
      $("#submit-button-2").hide();
      $("#warn-text").hide();
    }
    else{
      $("#submit-button-1").hide();
      $("#submit-button-2").show();
    }
  });

  $("#submit-button-2").click(function(){
      $("#warn-text").show();
  });