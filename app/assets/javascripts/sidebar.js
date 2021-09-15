function openSidebar() {
  $('#wc_sidebar').width("250px");
  $('#wc_sidebar').addClass("wc_sidebar_open");
  $('#wc_main').css["margin-right", "250px"];
}

function closeSidebar() {
  $('#wc_sidebar').removeClass("well");
  $('#wc_sidebar').removeClass("wc_sidebar_open");
  $('#wc_sidebar').width("0px");
  $('#wc_main').css["margin-right", "auto"];
}
function toggleSidebar() {
  if ($('#wc_sidebar').hasClass("wc_sidebar_open")) {
    closeSidebar();
  }
  else {
    openSidebar();
  }
}
