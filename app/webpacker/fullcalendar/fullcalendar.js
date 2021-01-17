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

var calendar_load = `
<div class="calendar_load container d-flex align-items-center justify-content-center">
	<div class="spinner-grow text-primary" role="status">
  	<span class="sr-only">読み込み中...</span>
	</div>
</div>
`;

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
				left: 'prevYear,prev,next,nextYear shikiri',
				center: '',
				right: 'title'
			},
			customButtons: {
				shikiri: {
					text: '仕切り',
					click: function() {
						location.href = '/oyster_invoices';
					}
				},
			},
			events: '/oyster_supplies.json?place=' + place,
			eventDidMount: function(info) {
				if ($(info.el).hasClass('supply_event')) {
					tippy('.tippy_' + info.event.extendedProps.supply_id, {
						onShow(instance) {
							instance.setContent(info.event.extendedProps.description)
						},
						allowHTML: true,
						animation: 'scale',
						duration: [100,0],
						touch: true,
						theme: 'supply_cal',
						touch: 'hold'
					});
				}
			},
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
				var difference = moment(end_date).diff(moment(start_date), "hours");
				if (difference > 24) {
					var display_end = moment(end_date).subtract(1, 'days').format('YYYY-MM-DD');
					$('#supply_action_date_title').html( '　(' + start_date + ' ~ ' + display_end + ')' )
					$.ajax({
						type: "GET",
						url: "/oyster_supplies/supply_action_nav/" + start_date + "/" + end_date,
					});
					$.ajax({
						type: "GET",
						url: "/oyster_supplies/supply_invoice_actions/" + start_date + "/" + end_date,
					});
					$.ajax({
						type: "GET",
						url: '/oyster_supplies/new_invoice/' + start_date + '/' + end_date + '/',
					});
					$('#supplyActionModal').modal('show')
				};
			},
			unselect: function(jsEvent, view) {
			},
			loading: function (loading) {
				if (loading) {
					$(calendarEl).prepend( calendar_load );
				} else {
					$('.calendar_load').remove()
				}
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
			selectable: true,
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
			loading: function (loading) {
				if (loading) {
					$(calendarEl).prepend( calendar_load );
				} else {
					$('.calendar_load').remove()
				}
			}
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
			selectable: false,
			dateClick: function(info) {
				window.location = 'profits/new/' + encodeURI(moment(info.date).format('YYYY年MM月DD日'));
			},
			loading: function (loading) {
				if (loading) {
					$(calendarEl).prepend( calendar_load );
				} else {
					$('.calendar_load').remove()
				}
			}
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
			selectable: false,
			events: '/profits.json',
			eventClick: function(info) {
				//
				},
			loading: function (loading) {
				if (loading) {
					$(calendarEl).prepend( calendar_load );
				} else {
					$('.calendar_load').remove()
				}
			}
	  	});
	};

	$('#ProfitModal').on('shown.bs.modal', function (e) {
		calendar.destroy();
		calendar.render();
		calendar.updateSize()
	})

});
