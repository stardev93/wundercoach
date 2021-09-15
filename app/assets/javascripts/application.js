// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require best_in_place
//= require jquery-ui/sortable
//= require jquery-ui/draggable
//= require jquery_ujs
//= require best_in_place.jquery-ui
//= require bootstrap
//= require moment
//= require moment/de
//= require bootstrap-datetimepicker
//= require pickers
//= require locales/bootstrap-datetimepicker.de
//= require chosen-jquery
//= require dropzone.min
//= require bootstrap-lightbox.min
//= require bootstrap3-editable/bootstrap-editable
//= require bootstrap-wysihtml5/index
//= require bootstrap-wysihtml5/locales/de-DE
//= require bootstrap-wysihtml5/locales/en-US
//= require jquery.minicolors
//= require jquery.minicolors.simple_form
//= require bootstrap-timepicker
//= require underscore
//= require gmaps/google
//= require 'icheck'
//= require 'trix'
//= require switchery
//= require listjs
//= require trix
//= require jsTimezoneDetect
//= require js.cookie
//= require browser_timezone_rails/set_time_zone
//= require fullcalendar
//= require fullcalendar/locale-all
//= require_directory .
//= require_directory ./admin/dashboard
//= require sidebar

$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
  jQuery(".best_in_place").hover(
    function() { $(this).addClass("best_in_place_hover"); },
    function() { $(this).removeClass("best_in_place_hover"); }
  );
});

$(function(){
  var hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + '"]').tab('show');

  $('.nav-tabs a').click(function (e) {
    $(this).tab('show');
    var scrollmem = $('body').scrollTop();
    window.location.hash = this.hash;
    $('html,body').scrollTop(scrollmem);
  });

  $('.nav-pills a').click(function (e) {
    $(this).tab('show');
    var scrollmem = $('body').scrollTop();
    window.location.hash = this.hash;
    $('html,body').scrollTop(scrollmem);
  });
});

$(function() {
  var elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));

  elems.forEach(function(html) {
    var switchery = new Switchery(html, { size: "small" });
  });
});
