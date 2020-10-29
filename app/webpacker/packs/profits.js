import 'bootstrap/js/dist/scrollspy';

$( document ).on('turbolinks:load', function() {

	// Profit Show view Scrollspy
	var sidebarEl = document.getElementById('profit_sidebar');
	if (sidebarEl) {
		$('body').scrollspy({ target: '#profit_sidebar' })
		$(window).on('activate.bs.scrollspy', function (e,obj) {
			if (($(obj.relatedTarget)).hasClass('card')) {
				$('#profit_sidebar').find('a.active').next('nav').addClass('active');
				$('#profit_sidebar').find('a').not(".active").next('nav').removeClass('active');
			};
		});
	};


	// Set up smoothscroll links for the profit show page
	$(".smoothscroll").click(function(event){
		event.preventDefault();
		//calculate destination place
		var dest=0;
		if ($(this.hash).offset().top > $(document).height()-$(window).height()) {
				dest=$(document).height()-$(window).height();
		}
		else{
				dest=$(this.hash).offset().top;
		}
		//go to destination
		$('html,body').animate({scrollTop:dest}, 400,'swing');
	});

	// Check to make sure we're on the profits pages
	if (/profits/.test(window.location.href)) {

		// Turn on warnings for unit price inputs without figures which have unit counts greater than zero
		(function($) {
			$.fn.toggleWarning = function() {
				return this.each(function() {
					if ($(this).val() != '') {
						var nextInput = $(this).parent().parent().next().find('input')
						if (nextInput.val() == '') {
							nextInput.addClass('bg-warning');
						}
					} else {
						$(this).parent().parent().next().find('input').removeClass('bg-warning');
					};
				});
			};
		})(jQuery);
		$(document).ready(function(){
			$('#partial .p_market_ordercount input').each(function() {
				$(this).toggleWarning()
			});
		});
		$('#partial .p_market_ordercount input').keyup(function(){
			$(this).toggleWarning()
		});
		$('#partial .p_market_unitcost input').keyup(function(){
			if ($(this).val() != '') {
				$(this).removeClass('bg-warning');
			};
		});

		// enter on the tab_edit form goes to next input with bg-warning
		var partialInputs = $('#partial input:visible:text')
		partialInputs.keyup(function (e) {
			if (e.which === 13) {
				var warningInputs = $('input.bg-warning:visible:text');
				if (warningInputs.length != 0) {
					var selectableWarns = $('input.bg-warning:visible:text')
					if ($(this).hasClass('bg-warning')) {
						var index = selectableWarns.index(this) + 1;
						selectableWarns.eq(index).focus();
					} else {
						selectableWarns.eq(0).focus();
					}
				} else {
					$.ajax({
						type: "GET",
						url: 'next_market',
						success: function() {
							//console.log('success')
						}
					});
				}
			}
		});

		// tab-edit page customizations

		if (/\/edit/.test(window.location.href)) {
			//Add autosave for when a market is expanded on the profit tab-edit page
			var id = (window.location.href).match(/\d*(?=\/edit)/)[0]
			$('body').bind('click keyup', function(event){
				$.ajax({
					type: "PATCH",
					url: "/profits/" + id + "/autosave_tab",
					dataType: "script",
					data: $(".edit_profit").serialize(),
					success: function() {
					}
				});
			});
			// Left/right keys as links to next market
			$('body').bind('keyup', function(e){
				if (e.keyCode == '37') {
					// left arrow
					var prev = $('#market-pills .active').prev('.nav-link')
					if (prev.length) {
						var url = prev.attr('href')
					} else {
						var url = $('#market-pills .nav-link').last().attr('href')
					}
					$.ajax({
						type: "GET",
						url: url,
						success: function() {
						}
					});
				};
				if (e.keyCode == '39') {
					// right arrow
					var next = $('#market-pills .active').next('.nav-link')
					if (next.length) {
						var url = next.attr('href')
					} else {
						var url = $('#market-pills .nav-link').first().attr('href')
					}
					$.ajax({
						type: "GET",
						url: url,
						success: function() {
						}
					});
				};
			});
		};


	};
});