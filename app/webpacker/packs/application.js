/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
// 

// JQuery setup
require('jquery')
require("@rails/ujs").start()
require('jquery-ui')

// Moment.js setup
const moment = require('moment');
require("moment")
require('moment/locale/ja');
moment.locale('ja');

//Fullcalendar Setup
require("fullcalendar/fullcalendar.js")

//Setup Bootstrap
import 'bootstrap'
require('bootstrap-datepicker')
//Tempusdominus
import "@fortawesome/fontawesome-free/js/all";
require('tempusdominus-bootstrap-4')

//Tippy.js for tooltips
import tippy from 'tippy.js';
import 'tippy.js/dist/tippy.css'; // optional for styling
window.tippy = tippy;
import 'tippy.js/animations/scale.css';

// Bootstrap Popovers, Datepickers, and Tippy.js intialization
$(document).on('turbolinks:load', function () {
	tippy('[data-tippy-content]', {allowHTML: true, animation: 'scale', duration: [300,0] });
	$('[data-toggle="popover"]').popover()
	$.fn.datetimepicker.Constructor.Default = $.extend({}, $.fn.datetimepicker.Constructor.Default, {
		icons: {
			time: 'far fa-clock',
			date: 'far fa-calendar',
			up: 'fas fa-arrow-up',
			down: 'fas fa-arrow-down',
			previous: 'fas fa-chevron-left',
			next: 'fas fa-chevron-right',
			today: 'far fa-calendar-check-o',
			clear: 'far fa-trash',
			close: 'far fa-times'
		},
		allowInputToggle: true,
		showClose: true
	 });
	$('.datetimepicker').datetimepicker({});
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
});

//Chartkick init
require("chartkick/chartkick.js")

//require("@rails/activestorage").start()
require("channels")

// Setup Turbolinks
var Turbolinks = require("turbolinks")
Turbolinks.start()