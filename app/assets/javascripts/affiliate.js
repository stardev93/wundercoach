$(document).ready(function() {
  var $startDatePicker = $('[name*=start_date]');
  var $endDatePicker = $('[name*=end_date]');
  $('.set_pickers').click(function(e) {
    e.preventDefault();
    $startDatePicker.val($(this).data('start_date'));
    $endDatePicker.val($(this).data('end_date'));
  });
});
