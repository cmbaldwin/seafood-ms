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