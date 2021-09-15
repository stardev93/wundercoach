# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->

  $("#event_longdescription_more").click (event) ->
    event.preventDefault()
    $("#event_longdescription").show()
    $("#event_longdescription_less").show()
    $("#event_longdescription_more").hide()

  $("#event_longdescription_less").click (event) ->
    event.preventDefault()
    $("#event_longdescription").hide()
    $("#event_longdescription_more").show()
    $("#event_longdescription_less").hide()
