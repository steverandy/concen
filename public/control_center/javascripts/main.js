$(document).ready(function() {
	
	$("a.inactive").live("click", function(){
		return false;
	});
	
	$("div.panel ul li p.right").each(function(index) {
		$(this).parents("li").eq(0).find("p:not(.right)").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
		$(this).parents("li").eq(0).find("a").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
	});
  
  if ($("#content-editor").length > 0) {
    var editor = ace.edit("content-editor");
    editor.getSession().setTabSize(2);
    editor.getSession().setUseSoftTabs(true);
    editor.setHighlightActiveLine(false);
    editor.setShowPrintMargin(false);
    editor.getSession().setUseWrapMode(true);
    editor.getSession().setValue($("#control_center_page_content").val());
    
    $("form.new_control_center_page, form.edit_control_center_page").submit(function() {
  	  var editorContent = editor.getSession().getValue();
  	  $("#control_center_page_content").val(editorContent);
    });
  };
	
});