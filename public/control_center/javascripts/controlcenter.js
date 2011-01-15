$(document).ready(function() {
	
	// $('#panels').equalHeights(true);
	
	$('#organize').bind({
		'ajax:beforeSend': function(){
			if ($(this).hasClass('active')) {
				$('nav a').removeClass('inactive');
				$(this).removeClass('active');
				$(this).text('Organize');
				$('div.squares-grid').enableSelection();
				$('div.squares-grid ul').removeClass('cursor-move');
				$('ul.squares-column li').removeClass('cursor-move');
				$('div.squares-grid').eq(0).sortable({
					disabled: true
				});
				// $('nav a').unbind('click');
			} else {
				$('nav a').addClass('inactive');
				$(this).removeClass('inactive');
				// $('nav a.inactive').click(function(){
				// 	return false;
				// });
				$(this).addClass('active');
				$(this).text('Done');
				$('div.squares-grid ul').addClass('cursor-move');
				$('ul.squares-column li').addClass('cursor-move');
				$('ul.squares-column li').addClass('cursor-move');
				$('div.squares-grid').disableSelection();
				$('div.squares-grid').eq(0).sortable({
					scroll: true,
					disabled: false,
					axis: 'x',
					containment: 'parent',
					tolerance: 'pointer',
					items: '.squares-column',
					cursor: 'move',
					update: function(event, ui) {
						$.ajax({
						  url: '/controlcenter/parents/sort',
						  type: 'PUT',
						  dataType: 'json',
						  data: $(this).sortable('serialize'),
						  success: function(data, textStatus, xhr) {
								if (data.success != true) {
									$('div.squares-grid').eq(0).sortable('cancel');
								};
						  }
						});
					}
				});
				$('ul.squares-column').sortable({
					scroll: true,
					disabled: false,
					axis: 'y',
					containment: 'parent',
					tolerance: 'pointer',
					items: 'li.child',
					update: function(event, ui) {
						$.ajax({
						  url: '/controlcenter/children/sort',
						  type: 'PUT',
						  dataType: 'json',
						  data: $(this).sortable('serialize'),
							cursor: 'move',
						  success: function(data, textStatus, xhr) {
								if (data.success != true) {
									$('ul.squares-column').sortable('cancel');
								};
						  }
						});
					}
				});
			}
			return false;
		},
		'ajax:success': function(data, status, xhr) {	
			return false;
		}
	});
	
	$('#file-list a.organize').bind({
		'ajax:beforeSend': function(){
			list = $(this).parents('div').eq(0).find('ul').eq(0);
			if ($(this).hasClass('active')) {
				$(this).removeClass('active');
				$(this).text('Organize');
				$(this).parents('div').eq(0).find('div.right').hide();
				list.enableSelection();
				list.eq(0).sortable({
					disabled: true
				});
			} else {
				$(this).addClass('active');
				$(this).text('Done');
				sortPath = $(this).parents('div').eq(0).find('a.sort-path').eq(0).attr('href')
				$(this).parents('div').eq(0).find('div.right').show();
				if (sortPath) {
					list.disableSelection();
					list.sortable({
						scroll: true,
						disabled: false,
						axis: 'y',
						containment: 'parent',
						tolerance: 'pointer',
						handle: 'div.right div.handle',
						opacity: '0.5',
						update: function(event, ui) {
							$.ajax({
							  url: sortPath,
							  type: 'PUT',
							  dataType: 'json',
							  data: $(this).sortable('serialize'),
							  success: function(data, textStatus, xhr) {
									if (data.success != true) {
										list.sortable('cancel');
									};
							  }
							});
						}
					});
				};
			}
			return false;
		},
		'ajax:success': function(data, status, xhr) {	
			return false;
		}
	});
	
	$("div.panels [title]").qtip({
		show: {
			delay: 0,
			when: {
				event: "click"
			}
		},
		hide: {
			when: {
				event: "unfocus"
			}
		},
		style: { 
			border: {
				width: 0,
				radius: 0,
				color: "white"
			},
			background: "white",
			color: "black",
			tip: {
				color: false,
				corner: "bottomMiddle",
				size: {x:0,y:0}
			}
		},
		position: {
			corner: {
				target: "topMiddle",
				tooltip: "bottomMiddle"
			},
			adjust: {
				y: -5
			}
		}
	});
	
});

window.autoRefresh = function(time) {
	if (typeof time == "undefined") { time = 10000 };
	setTimeout("location.reload(true);", time);
}