$(document).ready(function() {
  $("table.users input[type=checkbox]").change(function() {
    $.ajax({
      url: $(this).data("path"),
      type: "PUT",
      dataType: "json",
      data: {attribute: $(this).attr("name")},
      success: function(data, textStatus, xhr) {
        console.log(data);
      }
    });

  });
});
