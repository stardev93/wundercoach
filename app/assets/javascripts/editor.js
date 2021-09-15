$(document).ready(function() {
  $('textarea.editor').each(function() {
    $(this).wysihtml5({
      toolbar: { fa: true, color: true },
      locale: $(this).data('locale')
    });
  });
});
