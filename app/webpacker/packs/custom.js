$(document).on('turbolinks:load', function(){
	$('#sidebarCollapse').on('click', function () {
		$('#front_sidebar').toggleClass('active');
		$('#sidebar_spacer').toggleClass('active');
		$(this).toggleClass('active');
	});
});

// Fade Flash Notices
$( document ).on('turbolinks:load', function() {
   $('.alert').delay(500).fadeIn('normal', function() {
	  $(this).delay(2500).fadeOut();
   });
});

//adds datapicker to a input box (for dates, duh)
$( document ).on('turbolinks:load', function() {
	var datepicker = require('bootstrap-datepicker')
	$('.datepicker').datepicker({
		maxViewMode: 2,
		format: "yyyy年mm月dd日",
		todayBtn: "linked",
		language: "ja",
		daysOfWeekHighlighted: "0,3",
		todayHighlight: true,
		orientation: "bottom auto",
		toggleActive: true
		});
	var datetimepicker = require('tempusdominus-bootstrap-4')
	$.fn.datetimepicker.Constructor.Default = $.extend({}, $.fn.datetimepicker.Constructor.Default, {
		// config can go here
		});
	$('.datetimepicker').datetimepicker({});
});

//adds loading script to all putts in "load" added to class
$( document ).on('turbolinks:load', function() {
	$('.load').on('click', function() {
		var $this = $(this);
		var loadingText = '<i class="fa fa-circle-notch fa-spin"></i> 処理中...';
		if ($(this).html() !== loadingText) {
			$this.data('original-text', $(this).html());
			$this.html(loadingText);
		}
		setTimeout(function() {
			$this.html($this.data('original-text'));
		}, 10000);
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