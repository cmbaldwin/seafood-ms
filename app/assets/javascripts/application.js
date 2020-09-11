// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//
//= require moment
//= require moment/ja.js
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.ja.js
//= require tempusdominus-bootstrap-4
//= require jquery.ui.widget
//= require fullcalendar
//= require fullcalendar/locale-all
//= require chartkick
//= require Chart.bundle
//= require colorpicker/js/colorpicker.js
//= require freewall/freewall.js
//= require activestorage
//= require_self
//= require profits
//= require products
//= require oyster_supplies
//= require welcome
//= require noshis
//
//= require cable
//= require_tree ./channels
//
//= require turbolinks
//

// Calendar
function eventCalendar() {
	const place = $('#supply_calendar').attr("data-place");
	$('#supply_calendar').fullCalendar({
		locale: 'ja',
		plugins: [ 'interaction', 'dayGrid' ],
		header: {
			left: 'prev,next today shikiri',
			center: 'title',
			right: 'appendArea'
		},
		customButtons: {
			shikiri: {
				text: '仕切り',
				bootstrapFontAwesome: 'far fa-list-alt',
				click: function() {
					location.href = '/oyster_invoices';
				}
			},
			appendArea: {
				text: ''
			}
		},
		events: '/oyster_supplies.json?place=' + place,
		eventClick: function(info) {
			if (info.className == 'invoice_event') {
					$('#invoiceModal').modal('toggle');
					$.ajax({
						type: "GET",
						url: "/oyster_supplies/fetch_invoice/" + info.id,
						dataType: "script",
						data: info.id,
						success: function() {
						}
					});
				}
			},
		selectable: true,
		dayClick: function(date, jsEvent, view) {
			$('.fc-appendArea-button').remove();
			window.open(('/oyster_supplies/new_by/' + encodeURI(date)), '_top');
		},
		select: function(startDate, endDate) {
			var start_date = startDate.format();
			var end_date = endDate.format();
			while ($('.fc-appendArea-button').next('div').length) {
				$('.fc-appendArea-button').next('div').remove();
			}
			$('.fc-appendArea-button').parent().append('<div class="btn-toolbar" role="toolbar" aria-label="ツールバー"><div class="btn-group mr-2" role="group" aria-label="botton-group"><small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">支払明細書<br>プレビュー</small><div type="button" class="btn btn-small text-white btn-secondary btn-disabled cursor-help">生産者まとめ :</div><a type="button" class="pdf_btn btn-small btn btn-primary pl-1 pr-1" href="/oyster_supplies/payment_pdf/all/' + start_date + '/' + end_date + '/sakoshi", target="_blank">坂越</a><a type="button" class="pdf_btn btn btn-small btn-primary pl-1 pr-1" href="/oyster_supplies/payment_pdf/all/' + start_date + '/' + end_date + '/aioi", target="_blank">相生</a><a type="button" class="btn btn-secondary btn-small text-white btn-disabled cursor-help">各生産者:</a><a type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" href="/oyster_supplies/payment_pdf/individual/' + start_date + '/' + end_date + '/sakoshi", target="_blank">坂越</a><a type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" href="/oyster_supplies/payment_pdf/individual/' + start_date + '/' + end_date + '/aioi", target="_blank">相生</a><small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">仕切り作成<br>送信予約</small><a type="button" class="btn btn-small btn-success pl-1 pr-1" data-toggle="modal" data-target="#invoiceModal">作成画面</a></div></div>'
				);
			$.ajax({
				type: "GET",
				url: '/oyster_supplies/new_invoice/' + start_date + '/' + end_date + '/',
				dataType: "script",
				data: start_date + end_date,
				success: function() {
				}
			});
		},
		unselect: function(jsEvent, view) {

		}
  	});
	$('#yahoo_orders_calendar').fullCalendar({
		contentHeight: 450,
		aspectRatio: 1,
		locale: 'ja',
		plugins: [ 'interaction', 'dayGrid' ],
		header: {
			left: 'prev,next today',
			center: '',
			right: 'title'
		},
		customButtons: {
		},
		events: '/yahoo_orders.json',
		eventClick: function(info) {
			$.ajax({
				type: "GET",
				url: '/fetch_yahoo_list/' + encodeURI(moment(info.start._i).format('YYYY-MM-DD')),
				dataType: "script",
				data: info.start._i
			});
		},
		dayClick: function(info) {
			$.ajax({
				type: "GET",
				url: '/fetch_yahoo_list/' + encodeURI(moment(info._d).format('YYYY-MM-DD')),
				dataType: "script",
				data: info._d
			});
		},
		selectable: true,
		select: function(startDate, endDate) {
		},
		unselect: function(jsEvent, view) {
		}
  	});
};

function clearCalendar() {
  $('.fullCalendar').fullCalendar('delete');
  $('.fullCalendar').html('');
};

$(document).on('turbolinks:load', function(){
  eventCalendar();
});$(document).on('turbolinks:before-cache', clearCalendar);

// Fade Flash Notices
$( document ).on('turbolinks:load', function() {
   $('.alert').delay(500).fadeIn('normal', function() {
	  $(this).delay(2500).fadeOut();
   });
});

//all popovers on, make them appear on hover and stay open on click
$( document ).on('turbolinks:load', function() {
	$('[data-toggle="popover"]').popover({
			html: true,
			trigger: 'hover click'
	})
});

//all tooltips on for data-toggle tooltip marked tags
$(document).on('turbolinks:load', function() {
	$('[data-toggle="tooltip"]').tooltip();
})

//turn on colorpicker
$( document ).on('turbolinks:load', function() {
	$('#colorSelector').ColorPicker({
		color: '#0000ff',
		onShow: function (colpkr) {
			$(colpkr).fadeIn(500);
			return false;
		},
		onHide: function (colpkr) {
			$(colpkr).fadeOut(500);
			return false;
		},
		onChange: function (hsb, hex, rgb) {
			$('input#colorSelector').css('backgroundColor', '#' + hex);
			$('input#colorSelector').val('#' + hex);
		}
	});
});

//adds datapicker to a input box (for dates, duh)
$.fn.datetimepicker.Constructor.Default = $.extend({}, $.fn.datetimepicker.Constructor.Default, {
            icons: {
                time: 'far fa-clock',
                date: 'far fa-calendar',
            } });

$( document ).on('turbolinks:load', function() {
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
	$('.datetimepicker').datetimepicker({ 
		});
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


//freewall defaults
//
$( document ).on('turbolinks:load', function() {
	var wall = new Freewall("#freewall");
	wall.reset({
		selector: '.brick',
		animate: false,
		cellW: 370,
		cellH: 'auto',
		onResize: function() {
			wall.fitWidth();
			wall.fitHeight();
		},
	});
	wall.fitWidth();
	wall.fitHeight();
});
