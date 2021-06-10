$("#home_series").DataTable({
    paging: true,
    searching: false,
    ordering: false,
    language:{
        url: "/dataTable_portuguese.json"
    }
});
        
$("#submit_form_button").on("click", function(){

    $.post( '/contact_form' ,
        {
            phone: $("#form_phone").val(),
            message: $("#form_message").val()
        },
        function(data, status){
            if(status == "success" ){
                if(!data[0].hasOwnProperty("msg")){
                    // console.log(data)
                } else {
                    //erro
                    console.log(data[0]["msg"])
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