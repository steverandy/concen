//= require concen/ace/ace
//= require concen/fileuploader

$(document).ready(function() {
	$("#file-manager a.new-file").live("click", function(event) {
    var filename = prompt("Filename", "");
    if (filename) {
      $.post($(this).attr("href"), {filename: filename}, function(data, textStatus, xhr) {
        if (data.success) {
          $("#file-manager div.files").replaceWith(data.content);
        };
      });
    };
    event.preventDefault();
	});

	// Delete files.
  $("#file-manager a.delete").live("click", function(event) {
    if (confirm("Are you sure?") == true) {
      targetURL = $(this).attr("href");
      parentLi = $(this).parents("li").eq(0);
      $.ajax({
        url: targetURL,
        type: "DELETE",
        dataType: "json",
        success: function(data, textStatus, xhr) {
          if (data.success) {
            console.log(parentLi);
            parentLi.remove();
          };
        }
      });
    };
    event.preventDefault();
  });

  // Insert file path to text editor by drag and drop.
  setupFilePathDragDrop = function() {
    $("#file-manager a.filename").draggable( {
      revert: "invalid",
      helper: "clone"
    });
  	$("#text-editor").droppable({
  	  accept: ".filename",
  		drop: function(event, ui) {
        window.editor.insert(ui.draggable.data("path"));
  		}
  	});
  };

  setupFilePathDragDrop();

  // Setup text editor (ace.js).
	setupTextEditor = function() {
	  if ($("#text-editor").length > 0) {
      window.editor = ace.edit("text-editor");
      window.editor.setHighlightActiveLine(false);
      window.editor.setShowPrintMargin(false);
      window.editor.getSession().setValue($("textarea.text-editor-content").eq(0).val());
      window.editor.getSession().setTabSize(2);
      window.editor.getSession().setUseSoftTabs(true);
      window.editor.getSession().setUseWrapMode(true);
      window.editor.renderer.setShowGutter(false);

      $("form.with-text-editor").submit(function() {
        var editorContent = window.editor.getSession().getValue();
        $("textarea.text-editor-content").eq(0).val(editorContent);
      });
    };
	};

	setupTextEditor();

  // Text editor is resizable.
  resizableTextEditor = $("form.with-text-editor .border").eq(0)
  resizableTextEditor.resizable({
		minHeight: resizableTextEditor.height(),
		minWidth: resizableTextEditor.width(),
		maxWidth: resizableTextEditor.width(),
		stop: function(event, ui) {
		  $("#text-editor").css("height", $("#text-editor").parent().height());
      window.editor.resize();
		}
  });

  // Setup file uploader. Support multiple files upload and drag and drop.
  if ($("#file-uploader").length > 0) {
    var uploader = new qq.FileUploader({
      element: $("#file-uploader")[0],
      action: $("#file-uploader").data("upload-path"),
      params: {},
      sizeLimit: 0, // max size
      minSizeLimit: 0, // min size
      debug: false,
      csrf: true,
      template: "<div class='qq-uploader'>" +
                  "<div class='qq-upload-drop-area'><span>Drop files here to upload</span></div>" +
                  "<div class='qq-upload-button'>Upload Files</div>" +
                  "<ul class='qq-upload-list'></ul>" +
                "</div>",
      onComplete: function(id, fileName, responseJSON){
        if (responseJSON.success) {
          $("#file-manager ul.qq-upload-list li.qq-upload-success").remove();
          $("#file-manager div.files").replaceWith(responseJSON.content);
          setupFilePathDragDrop();
        };
      },
      showMessage: function(message){ alert(message); }
    });
  };

  $("ul.pages").nestedSortable({
		disableNesting: "no-nest",
		forcePlaceholderSize: true,
		helper:	"clone",
		handle: "span.handle",
		items: "li",
		maxLevels: 0,
		opacity: .6,
		placeholder: "placeholder",
		revert: 250,
		tabSize: 25,
		tolerance: "pointer",
		toleranceElement: "> p",
		listType: "ul",
		update: function(event, ui) {
		  data = $("ul.pages").nestedSortable("serialize", {"attribute": "data-id"});
		  console.log(data);
		  if ($("ul.pages > li").length > 1) {
		    $("ul.pages").nestedSortable("cancel")
		  } else {
		    $.ajax({
          url: "/pages/sort",
          type: "PUT",
          dataType: "json",
          data: data,
          success: function(data, textStatus, xhr) {
            if (!data.success) {
              $("ul.pages").nestedSortable("cancel");
            };
            // $(this).sortable("cancel");
          }
        });
		  };
		},
	});

	$("ul.pages a.title").live("click", function(event) {
	  if ($(this).hasClass("active")) {
	    $(this).removeClass("active");
	    $(this).parent().find("a.link-button").addClass("hidden");
	    window.location = $(this).attr("href");
	  } else {
	    $("ul.pages a.title").removeClass("active");
	    $("ul.pages a.link-button").addClass("hidden");
	    $(this).addClass("active");
	    $(this).parent().find("a.link-button").removeClass("hidden");
	  };
    event.preventDefault();
	});
});
