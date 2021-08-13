$("#submit_form_button").on("click", function(){
    
    $(".success-msg").hide();

    $.post( '/contact_form' ,
        {
            phone: $("#form_phone").val(),
            message: $("#form_message").val()
        },
        function(data, status){
            if(status == "success" ){
                if(!data[0].hasOwnProperty("msg")){

                } else {
                    
                    $(".success-msg").show();
                    $(".succes").html(data[0]["msg"])
                }
            } else {
                //ERRO DE REQUISIÇÃO
            }
        })

})

$("#form_message").on("keyup", function(){
    var length = $(this).val().length

    if (length > 0){
        $("#submit_form_button").show();
        $("#fake_form_button").hide();
    }

    else{
        $("#submit_form_button").hide();
        $("#fake_form_button").show();
    }
})

$("#fake_form_button").on("click", function(){
    $("#form_message").css({"border":"#F70000 solid 2px"})
})

$("#submit_form_button").on("click", function(){
    $("#form_message").val("");
    $("#form_phone").val("");

})