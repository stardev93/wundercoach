$(document).ready(function(){
  $("input.paymentplanfeatures").on("change keyup", function(){
    value = $(this).data("id");
    content = $(this).val();

    var route = "paymentplanfeatures/" + value;
    $.ajax({
      type: "PUT",
      url: route,
      data: {value: content},
      dataType: "json"
    });
  });

  $(function  () {
    $("#function-feature tbody").sortable({
      placeholder: "ui-state-highlight",
      opacity: 0.6,
      start: function(event, ui) {
            var start_pos = ui.item.index();
            ui.item.data('start_pos', start_pos);
        },
      update: function(event, ui){
        var position = ui.item.index() + 1;
        $.ajax({
         type: "POST",
         url: "/de/features/" + ui.item.data("id") + "/position",
         data: {position: position},
       });
      }
    });
  });

});
