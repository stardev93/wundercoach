# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $(".chosen-select").chosen()
  $("#eventbooking_billing_address").click ->
    $("#billing_address").toggle()
    #alert($("#eventbooking_billing_address").value())

  $("#event_early_signup_pricing").click ->
    $(".event_early_signup_pricing_toggle").toggle()
