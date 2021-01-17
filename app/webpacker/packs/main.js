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
});

// Sidebar collapse functions
$(document).on('turbolinks:load', function(){
	$('#sidebar_button').on('click', function(){
		$.ajax({
			type: "GET",
			url: "/refresh_messages/",
		});
	})
});

// Fade Flash Notices
$( document ).on('turbolinks:load', function() {
   $('.alert').delay(500).fadeIn('normal', function() {
	  $(this).delay(2500).fadeOut();
   });
});

//select all checkboxes with the select_all class
$( document ).on('turbolinks:load', function() {
	$('form').find('div.noshi :checkbox').each(function () {

	});
	$('#select_all').click (function () {
		var checkedStatus = this.checked;
		$('form').find('div.noshi_card :checkbox').each(function () {
				$(this).prop('checked', checkedStatus);
		});
	});
});


// Restricts input for the given textbox to the given inputFilter. See: https://jsfiddle.net/emkey08/tvx5e7q3
// And also adds mousewheel up/down incrementalization for inputs
$( document ).on('turbolinks:load', function() {
	(function($) {
	  $.fn.inputFilter = function(inputFilter) {
		return this.on("input keydown keyup mousedown mouseup select contextmenu drop", function() {
		  if (inputFilter(this.value)) {
			this.oldValue = this.value;
			this.oldSelectionStart = this.selectionStart;
			this.oldSelectionEnd = this.selectionEnd;
		  } else if (this.hasOwnProperty("oldValue")) {
			this.value = this.oldValue;
			this.setSelectionRange(this.oldSelectionStart, this.oldSelectionEnd);
		  }
		});
	  };
	}(jQuery));

	// Install input filters.
	$(".intTextBox").inputFilter(function(value) {
	  return /^-?\d*$/.test(value); });
	$(".uintTextBox").inputFilter(function(value) {
	  return /^\d*$/.test(value); });
	$(".intLimitTextBox").inputFilter(function(value) {
	  return /^\d*$/.test(value) && (value === "" || parseInt(value) <= 500); });
	$(".floatTextBox").inputFilter(function(value) {
	  return /^-?\d*[.,]?\d*$/.test(value); });
	$(".currencyTextBox").inputFilter(function(value) {
	  return /^-?\d*[.,]?\d{0,2}$/.test(value); });
	$(".hexTextBox").inputFilter(function(value) {
	  return /^[0-9a-f]*$/i.test(value); });

});
