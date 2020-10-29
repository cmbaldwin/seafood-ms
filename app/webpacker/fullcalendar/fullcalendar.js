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

	if (calendarEl) {
		var calendar = new Calendar(calendarEl, {
		    plugins: [ dayGridPlugin, interactionPlugin ],
			locale: 'ja',
			contentHeight: 800,
			aspectRatio: 1.35,
			themeSystem: 'bootstrap',
			headerToolbar: {
				left: 'prevYear,prev,next,nextYear shikiri title',
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
				if (($('.fc-highlight').last().width() > $('.fc-daygrid-day').width() + 10) || ($('.fc-highlight').length > 1)) {
					$('.fc-appendArea-button').parent().append(`
						<div class="btn-toolbar" id="select_toolbar" role="toolbar" aria-label="ツールバー">
							<div class="btn-group mr-2" role="group" aria-label="botton-group">
								<small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">
									支払明細書<br>プレビュー
								</small>
								<div type="button" class="btn btn-small text-white btn-secondary btn-disabled cursor-help">
									生産者まとめ :
								</div>
								<div type="button" class="pdf_btn btn-small btn btn-primary pl-1 pr-1" data-location="sakoshi" data-format="all" data-start="` + start_date + `" data-end="` + end_date + `">
									坂越
								</div>
								<div type="button" class="pdf_btn btn btn-small btn-primary pl-1 pr-1" data-location="aioi" data-format="all" data-start="` + start_date + `" data-end="` + end_date + `">
									相生
								</div>
								<div type="button" class="btn btn-secondary btn-small text-white btn-disabled cursor-help">
									各生産者:
								</div>
								<div type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" data-location="sakoshi" data-format="individual" data-start="` + start_date + `" data-end="` + end_date + `">
									坂越
								</div>
								<div type="button" class="pdf_btn btn btn-small btn-info pl-1 pr-1" data-location="aioi" data-format="individual" data-start="` + start_date + `" data-end="` + end_date + `">
									相生
								</div>
								<small class="badge align-middle text-wrap btn btn-white pt-2 border border-grey cursor-default">
									仕切り作成<br>送信予約
								</small>
								<div type="button" class="btn btn-small btn-success pl-1 pr-1" data-toggle="modal" data-target="#invoiceModal">
									作成画面
								</div>
							</div>
						</div>
					`);
				}
				$.ajax({
					type: "GET",
					url: '/oyster_supplies/new_invoice/' + start_date + '/' + end_date + '/',
					dataType: "script",
					data: start_date + end_date,
					success: function() {
					}
				});
				$('.pdf_btn').bind('click', function(event){
					var format = $(this).attr('data-format')
					var start_date = $(this).attr('data-start')
					var end_date = $(this).attr('data-end')
					var location = $(this).attr('data-location')
					$.ajax({
						type: "GET",
						url: "/oyster_supplies/payment_pdf/" + format + "/" + start_date + "/" + end_date + "/" + location,
					});
				});
			},
			unselect: function(jsEvent, view) {
			}
	  	});
	};

	if (calendarEl) {
		calendar.destroy();
		calendar.render();
		calendar.updateSize()
	};
});

// Yahoo Orders Calendar
document.addEventListener('turbolinks:load', function() {

	var calendarEl = document.getElementById('yahoo_orders_calendar');

	if (calendarEl) {
		var calendar = new Calendar(calendarEl, {
		    plugins: [ dayGridPlugin, interactionPlugin ],
			locale: 'ja',
			contentHeight: 450,
			aspectRatio: 1,
			headerToolbar: {
				left: 'prevYear,prev,next,nextYear',
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
	  };


	if (calendarEl) {
		calendar.destroy();
		calendar.render();
		calendar.updateSize()
	};
});


// New Profit Calendar
document.addEventListener('turbolinks:load', function() {

	var calendarEl = document.getElementById('new_profit_calendar');

	if (calendarEl) {
		var calendar = new Calendar(calendarEl, {
		    plugins: [ dayGridPlugin, interactionPlugin ],
			locale: 'ja',
			contentHeight: 450,
			aspectRatio: 1,
			headerToolbar: {
				left: 'prevYear,prev,next,nextYear',
				center: '',
				right: 'title'
			},
			customButtons: {
			},
			dateClick: function(info) {
				window.location = 'profits/new/' + encodeURI(moment(info.date).format('YYYY年MM月DD日'));
			},
			selectable: false
	  	});
	  };

	$('#newProfitModal').on('shown.bs.modal', function (e) {
		calendar.destroy();
		calendar.render();
		calendar.updateSize()
	})

});

// Profit Calendar
document.addEventListener('turbolinks:load', function() {

	var calendarEl = document.getElementById('profit_calendar');

	if (calendarEl) {
		var calendar = new Calendar(calendarEl, {
		    plugins: [ dayGridPlugin, interactionPlugin ],
			locale: 'ja',
			headerToolbar: {
				left: 'prevYear,prev,next,nextYear',
				center: '',
				right: 'title'
			},
			customButtons: {
			},
			events: '/profits.json',
			eventClick: function(info) {
				//
				},
			selectable: false
	  	});
	};

	$('#ProfitModal').on('shown.bs.modal', function (e) {
		calendar.destroy();
		calendar.render();
		calendar.updateSize()
	})

});