import flatpickr from "flatpickr";
window.flatpickr = flatpickr
import { Japanese } from "flatpickr/dist/l10n/ja.js"
//require("flatpickr/dist/themes/material_blue.css"); //required in application.scss

$('.datetimepicker').flatpickr({
		"locale": Japanese,
		enableTime: true,
		dateFormat: "Y年m月d日 H:i",
		monthSelectorType: 'static',
	}
);

$('.datepicker').flatpickr({
		"locale": Japanese,
		enableTime: false,
		dateFormat: "Y年m月d日",
		monthSelectorType: 'static',
	}
);