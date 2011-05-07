$(document).ready(function() {
	
	$("a.inactive").live("click", function(){
		return false;
	});
	
	$("div.panel ul li p.right").each(function(index) {
		$(this).parents("li").eq(0).find("p:not(.right)").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
		$(this).parents("li").eq(0).find("a").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
	});
  
  if ($("#text-editor").length > 0) {
    var editor = ace.edit("text-editor");
    editor.getSession().setTabSize(2);
    editor.getSession().setUseSoftTabs(true);
    editor.setHighlightActiveLine(false);
    editor.setShowPrintMargin(false);
    editor.getSession().setUseWrapMode(true);
    editor.getSession().setValue($("textarea.text-editor-content").eq(0).val());
    
    $("form.with-text-editor").submit(function() {
  	  var editorContent = editor.getSession().getValue();
  	  $("textarea.text-editor-content").eq(0).val(editorContent);
  	  console.log($("textarea.text-editor-content").eq(0).val());
    });
  };
  
  if ($("#file-uploader").length > 0) {
    var uploader = new qq.FileUploader({
      // pass the dom node (ex. $(selector)[0] for jQuery users)
      element: $("#file-uploader")[0],
      // path to server-side upload script
      action: $("#file-uploader").data("upload-path"),
      // additional data to send, name-value pairs
      params: {},
      // validation
      // ex. ['jpg', 'jpeg', 'png', 'gif'] or []
      allowedExtensions: [],        
      // each file size limit in bytes
      // this option isn't supported in all browsers
      sizeLimit: 0, // max size
      minSizeLimit: 0, // min size
      // set to true to output server response to console
      debug: false,
      // events         
      // you can return false to abort submit
      onSubmit: function(id, fileName){},
      onProgress: function(id, fileName, loaded, total){},
      onComplete: function(id, fileName, responseJSON){},
      onCancel: function(id, fileName){},
      messages: {
          // error messages, see qq.FileUploaderBasic for content            
      },
      showMessage: function(message){ alert(message); }
    });
  };
  
  // $("ul.pages").sortable({
  //   scroll: true,
  //   items: "li",
  //   connectWith: ".connected-sortable",
  //   update: function(event, ui) {
  //     data = {pages: []};
  //     $(this).find("> li").each(function(index) {
  //       data.pages[index] = $(this).data("id");
  //     });
  //     data.level = $(this).data("level");
  //     data.parent_id = $(this).parent().data("id");
  //      $.ajax({
  //        url: "/pages/sort",
  //        type: "PUT",
  //        dataType: "json",
  //        data: data,
  //        success: function(data, textStatus, xhr) {
  //          $(this).sortable("cancel");
  //        }
  //      });
  //    },
  //    
  // });
  
  
  $("ul.pages").nestedSortable({
		disableNesting: 'no-nest',
		forcePlaceholderSize: true,
		helper:	'clone',
		items: 'li',
		maxLevels: 3,
		opacity: .6,
		placeholder: 'placeholder',
		revert: 250,
		tabSize: 25,
		tolerance: 'pointer',
		toleranceElement: '> p',
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
            $(this).sortable("cancel");
          }
        });
		  };
		},
	});
  
	
});