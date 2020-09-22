// Init FullCalendar
import { Calendar } from "@fullcalendar/core";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";

// Not in use right now
// import bootstrapPlugin from "@fullcalendar/bootstrap";
// import listPlugin from "@fullcalendar/list";
// import timeGridPlugin from "@fullcalendar/timegrid";

// Calendars cause console errors for every page they don't exist on
// Researching ways to avoid this in the future
// Including an "if calendarEl exists then render" type of function
// solves the error problem, but renders from previous calendar settings

// Oyster Supplies Calendar
document.addEventListener('turbolinks:load', function() {
	var calendarEl = document.getElementById('supply_calendar');
	var place = $('#supply_calendar').attr("data-place");

	var calendar = new Calendar(calendarEl, {
	    plugins: [ dayGridPlugin, interactionPlugin ],
		locale: 'ja',
		contentHeight: 700,
		aspectRatio: 1.35,
		themeSystem: 'bootstrap',
		headerToolbar: {
			left: 'prev,next shikiri title',
			center: '',
			right: 'appendArea'
		},
		customButtons: {
			shikiri: {
				text: '仕切り',
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
		dateClick: function(info) {
			$('.fc-appendArea-button').remove();
			window.open(('/oyster_supplies/new_by/' + encodeURI(info.date)), '_top');
		},
		select: function(info) {
			var start_date = info.startStr
			var end_date = info.endStr
			while ($('.fc-appendArea-button').next('div').length) {
				$('.fc-appendArea-button').next('div').remove();
			}
			$('.fc-appendArea-button').parent().append('<div class="btn-toolbar" role="toolbar" aria-label="ツールバー"><div class="btn-group mr-2" role="group" aria-label="botton-group"><small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">支払明細書<br>プレビュー</small><div type="button" class="btn btn-small text-white btn-secondary btn-disabled cursor-help">生産者まとめ :</div><a type="button" class="pdf_btn btn-small btn btn-primary pl-1 pr-1" href="/oyster_supplies/payment_pdf/all/' + start_date + '/' + end_date + '/sakoshi", target="_blank">坂越</a><a type="button" class="pdf_btn btn btn-small btn-primary pl-1 pr-1" href="/oyster_supplies/payment_pdf/all/' + start_date + '/' + end_date + '/aioi", target="_blank">相生</a><a type="button" class="btn btn-secondary btn-small text-white btn-disabled cursor-help">各生産者:</a><a type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" href="/oyster_supplies/payment_pdf/individual/' + start_date + '/' + end_date + '/sakoshi", target="_blank">坂越</a><a type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" href="/oyster_supplies/payment_pdf/individual/' + start_date + '/' + end_date + '/aioi", target="_blank">相生</a><small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">仕切り作成<br>送信予約</small><a type="button" class="btn btn-small btn-success pl-1 pr-1" data-toggle="modal" data-target="#invoiceModal">作成画面</a></div></div>');
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

	if (calendarEl) {
		calendar.render();
		calendar.updateSize()
	};
});

// Yahoo Orders Calendar
document.addEventListener('turbolinks:load', function() {

	var calendarEl = document.getElementById('yahoo_orders_calendar');

	var calendar = new Calendar(calendarEl, {
	    plugins: [ dayGridPlugin, interactionPlugin ],
		locale: 'ja',
		contentHeight: 450,
		aspectRatio: 1,
		headerToolbar: {
			left: 'prev,next',
			center: '',
			right: 'title'
		},
		customButtons: {
		},
		events: '/yahoo_orders.json',
		eventClick: function(info) {
			$.ajax({
				type: "GET",
				url: '/fetch_yahoo_list/' + encodeURI(moment(info.event.start).format('YYYY-MM-DD')),
				dataType: "script",
				data: info.event.start
			});
		},
		dateClick: function(info) {
			$.ajax({
				type: "GET",
				url: '/fetch_yahoo_list/' + encodeURI(moment(info.date).format('YYYY-MM-DD')),
				dataType: "script",
				data: info.date
			});
		},
		selectable: true
  	});


	if (calendarEl) {
		calendar.render();
		calendar.updateSize()
	};
});