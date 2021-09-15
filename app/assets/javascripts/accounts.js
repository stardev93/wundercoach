$(document).ready(function(){

  var response_action = $( ".response_action" ).val();
  var response_element = $( "#response_element" ).val();

  // disable auto discover
  Dropzone.autoDiscover = true;

  // grab our upload form by its id (class?)
  $(".dropzone").each(function() {
    $(this).dropzone({
      // restrict image size to a maximum 100MB
      maxFilesize: 200,
      // changed the passed param to one accepted by
      // our rails app
      // paramName: "account[eventheader]",

      paramName: this.dataset.param,
      // show remove links on each image upload
      addRemoveLinks: false,
      // if the upload was successful
      success: function(file, response){
        var $uploadtable = $("#" + response_element);
        // find the remove button link of the uploaded file and give it an id
        // based of the fileID response from the server
        $(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");

        $uploadtable.load(response_action);
        // $uploadtable.load("taskassetlist");
        location.reload();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');

        // make a DELETE ajax request to delete the file
        $.ajax({
          type: 'DELETE',
          url: '/accounts/' + id,
          success: function(data){
            console.log(data.message);
          }
        });
      }
    });
  });
});
