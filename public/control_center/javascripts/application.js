$(document).ready(function() {
	
	$('a.inactive').live('click', function(){
		return false;
	});
	
	$('div.panel ul li p.right').each(function(index) {
		$(this).parents('li').eq(0).find('p:not(.right)').width($(this).parents('li').eq(0).width() - $(this).innerWidth());
		$(this).parents('li').eq(0).find('a').width($(this).parents('li').eq(0).width() - $(this).innerWidth());
	});
	
});