$(document).ready(function() {
  $( ".draggable" ).draggable({ handle: "i", cursor: "move", cursorAt: { top: 10, left: 10 }, revert: false, opacity: 0.7, helper: "clone" });
  $("[data-behaviour~=chosen]").chosen({
        allow_single_deselect: false,
        no_results_text: 'No results matched',
        width: '200px'
      });
  $('#eventbooking_user_id_chosen').width('100%');

  $('.datepicker').datetimepicker({
    icons: {
      date: 'fa fa-calendar',
      time: 'fa fa-clock-o',
      up: 'fa fa-chevron-up',
      down: 'fa fa-chevron-down',
      previous: 'fa fa-chevron-left',
      next: 'fa fa-chevron-right',
      today: 'fa fa-crosshairs',
      clear: 'fa fa-trash-o',
      close: 'fa fa-times'
    }
  });

  $('.date_time_picker .input-group').each(function(){
    $(this).datetimepicker({
      icons: {
        date: 'fa fa-calendar',
        time: 'fa fa-clock-o',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-crosshairs',
        clear: 'fa fa-trash-o',
        close: 'fa fa-times'
      },
      format: "YYYY-MM-DD HH:mm:ss",
      locale: "de"
    });
  });
});
$('input[type=time]').timepicker({
  minuteStep: 5,
  showMeridian: false
});
