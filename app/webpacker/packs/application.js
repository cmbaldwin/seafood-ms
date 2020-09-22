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
document.addEventListener("turbolinks:load", () => {
	$('[data-toggle="tooltip"]').tooltip()
	$('[data-toggle="popover"]').popover()
})
require('bootstrap-datepicker')
//Temporary usage of beta-ish tempusdominus /w FA
import "@fortawesome/fontawesome-free/js/all";
require('tempusdominus-bootstrap-4')

//Chartkick init
require("chartkick/chartkick.js")

//require("@rails/activestorage").start()
require("channels")

// Setup Turbolinks
var Turbolinks = require("turbolinks")
Turbolinks.start()