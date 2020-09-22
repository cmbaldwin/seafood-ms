$( document ).on('turbolinks:load', function() {

		// Set up scrollspy sticky navigation and smooth scrolllinks for the profit show page
		var scrollspy = require('scrollspy')

		$('.fixed_nav_container').each(function() {
		        var me = this
		        var $me = $(me)
		        scrollspy.add(me, {
		                scrollIn: function() {
		                        $me.addClass('show')
		                },
		                scrollOut: function() {
		                        $me.removeClass('show')
		                }
		        })
		})

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
							index = selectableWarns.index(this) + 1;
							selectableWarns.eq(index).focus();
						} else {
							selectableWarns.eq(0).focus();
						}
					} else {
						var index = partialInputs.index(this) + 1;
						partialInputs.eq(index).focus();
					}
				}
			});

			// Add autosave for when a market is expanded on the profit tab-edit page
			if (/\/edit/.test(window.location.href)) {
				var id = (window.location.href).match(/\d*(?=\/edit)/)[0]
				$('body').bind('click keyup', function(event){
					$.ajax({
						type: "PATCH",
						url: "/profits/" + id + "/autosave_tab",
						dataType: "script",
						data: $(".edit_profit").serialize(),
							success: function() {
								//$("#autosave_notice").fadeIn().delay( 2500 ).fadeOut();
							}
					});
				});
			};


		};
});