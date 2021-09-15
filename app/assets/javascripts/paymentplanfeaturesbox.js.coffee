Paymentplanfeatures =
  init : ->
    _that = this


$(document).ready ->
  Paymentplanfeatures.init()


# refresh cell when new Paymentplanfeature was added via ajax
# add loading indicator
$(document).on "ajax:beforeSend", ".paymentplanfeatures-remote-call", ->
  $(this).find("i").addClass("fa-spinner fa-spin")

$(document).on "ajax:success", ".paymentplanfeatures-remote-call", (e, data, status, xhr) ->
  $(this).find("i").removeClass("fa-spinner fa-spin")
  $(this).replaceWith(data)
