// Updates the "show_get_started_modal" preference of an account,
// every time the getting started modal is closed
$(document).ready(function() {
  // on closing the modal:
  $("#getting_started").on("hide.bs.modal", function(e) {
    // Update account preferences
    $.post(
      "/de/account/preferences",
      {
        _method: "patch",
        account: {
          show_get_started_modal: !$("#getting_started .hide-modal-forever").is(":checked"),
        }
      }
    );
    // Show a popover that tells the customer where to find getting started help
    $('#getting_started_popover')
      .popover({
        content: I18n['find_start_help_here'],
        container: "body",
        placement: "bottom",
        trigger: "manual"
      })
      .popover('show');
    setTimeout(function () {
      $('#getting_started_popover').popover('destroy')
    }, 4000);
  });
});
