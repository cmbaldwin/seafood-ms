$( document ).on('turbolinks:load', function() {

	//On click previous/next buttons get JSON data for that month
	var year_month = $(".fc-header-toolbar .fc-center").text()
	$('.fc-next-button','.fc-prev-button').bind('click', function(event){
		$.ajax({
			type: "GET",
			url: "/oyster_supplies/fetch_supplies/" + start + "/" + end,
			dataType: "script",
			data: year_month,
			success: function() {
			}
		});
	});

	// Calendar Setup
	$('.fc-appendArea-button').addClass('d-none').attr('disabled', 'disabled').removeClass('fc-button fc-state-default fc-corner-left fc-corner-right');
	$('.fc-center').addClass('float-left ml-3');
	$('#supply_calendar .fc-body').click(function(event){
		event.stopPropagation();
	});
	$("body").click(function(event) {
		while ($('.fc-appendArea-button').next('div').length) {
			$('.fc-appendArea-button').next('div').remove();
		}
	}); 

	// When to perform the calculations
	$(document).ready(calculate);   
	$(document).on("keyup", calculate);

	// Calculate subtotals, totals, and display alerts 
	function calculate(){
		var tables = $('table.table.table-striped');
		var subtotal_l = $('.subtotal_l');
		var subtotal_u = $('.subtotal_u');
		var subtotal_lu = $('.subtotal_lu');
		var muki_total = $('.muki_total');
		var suppliers = $('.supplier_name')
		var volume_subtotal = $('.volume_subtotal'); 
		var price_input = $('.price-input');
		var type_subtotal = $('.type_subtotal');
		var tax_added_subtotal = $('.tax_added_subtotal');
		var supplier_total = $('.supplier_total');
		const tax = parseFloat($('#oyster_supply_oysters_tax').val());

		subtotal_l.each(function(index) {
			var columns = $(this).parent('tr').children('td');
			var col_num = columns.length - 1;
			var subtotal = 0;
			columns.each(function(index) {
				if (index < col_num) {
					var current = $(this).find('input').val();
					subtotal += parseFloat(current);
				};
			});
			$(this).html(subtotal);
		});

		// Subtotals calculated by adding the values above it (as per each supplier per time period)
		subtotal_u.each(function(index) {
			var columns = $(this).parent('tr').children('td').length;
			var position = $(this).index() - 1;
			var rows = $(this).parent('tr').prevUntil('.left_head', 'tr');
			var subtotal = 0;
			rows.each(function(index) {
				var cell = $(this).find('td').get(position);
				var value = $(cell).find('input').val();
				subtotal += parseFloat(value);
			});
			$(this).find('input').val(subtotal);
		});

		// Subtotals calculated by adding up (but also should be the same as the sum of the left values)
		subtotal_lu.each(function(index) {
			var position = $(this).index() - 1;
			var rows = $(this).parent('tr').prevUntil('.left_head', 'tr');
			var subtotal = 0;
			rows.each(function(index) {
				var cell = $(this).find('td').get(position);
				var value = $(cell).html();
				subtotal += parseFloat(value);
			});
			$(this).html(subtotal);
		});

		// Subtotals calculated by adding cells from the right
		tables.each(function(index) {
			var total = 0;
			var subtotals = $(this).find('.subtotal_lu');
			subtotals.each(function(index) {
				value = $(this).html();
				total += parseFloat(value);
			});
			ran = $(this).find('.ran').html();
			total += parseFloat(ran);
			$(this).find('#total').html(total);
		});

		// Combined shucked volume subtotals
		muki_total.each(function(index) {
			var subtotal = 0;
			var position = $(this).index();
			var rows = $(this).parent().prevUntil('thead', 'tr.subtotal_row');
			rows.each(function(index) {
				var cell = $(this).find('th').get(position);
				var value = $(cell).find('input').val();
				subtotal += parseFloat(value);
			});
			$(this).html(subtotal);
		});

		// Calculate combined morning and evening subtotals
		volume_subtotal.each(function(index) {
			var type_name = $(this).find('input').attr('name').replace('oyster_supply[oysters][', '').replace('][volume]]', '').replace(/\d/gi, "").replace("[", "");
			var supplier_id = $(this).find('input').attr('name').replace('oyster_supply[oysters][', '').replace('][volume]]', '').replace("[", "").replace("_", "").replace(/([a-z]*)/gi, "");
			var subtotals = $('.subtotal_row input[id*="\[' + type_name + '\]"][id*="\[' + supplier_id + '\]"]'); 
			var total = 0;
			subtotals.each (function () {
				total += parseFloat($(this).val());
			});
			$(this).find('input').val(total);
		});

		// If Volume Subtotal isn't 0 and Price Input IS 0 then give a visual alert for the input
		price_input.each(function(index) {
			var price = parseFloat($(this).find('input').val());
			var volume = parseFloat($(this).next().find('input').val());;
			if ((volume != 0) && (price == 0)) {
				$(this).find('input').addClass("bg-warning");
			} else {
				$(this).find('input').removeClass("bg-warning");
			};
		});
		// Extend this visual alert to the total card for each supplier
		suppliers.each(function(index) {
			rows = $(this).nextUntil('.supplier_last').addBack().next();
			need = false;
			rows.each(function(){
				if ($(this).find('input').hasClass('bg-warning')) {
					need = true;
				};
			});
			if (need === true) {
				$(this).next().find('.card').addClass('border-warning');
			} else {
				$(this).next().find('.card').removeClass('border-warning');
			};
		});

		// Calculate price multiplied by volume for each type
		type_subtotal.each(function(index) {
			price = $(this).parent().prev().find('input').val();
			volume = $(this).parent().prev().prev().find('input').val();
			$(this).html((parseFloat(price) * parseFloat(volume)).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
			$(this).parent().find('input').val(parseFloat(price) * parseFloat(volume));
		});

		// Calculate the tax added subtotal
		tax_added_subtotal.each(function(index) {
			subtotal = parseFloat($(this).prev().find('.type_subtotal').html());
			$(this).find('input').val(parseFloat(subtotal * tax));
		});

		// Calculated the tax added total for each supplier
		supplier_total.each(function(index) {
			var current_row = $(this).parents('tr');
			var next_rows = $(this).parents('tr').nextAll().slice(0,5);
			var rows = current_row.add(next_rows);
			total = 0
			rows.each(function() {
				var subtotal = parseFloat($(this).find('.type_subtotal').html().replace(/,/g, ''));
				total += subtotal
			});
			rows.find('.before_tax_total').html(total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
			var tax_only = tax - 1;
			$(this).parent().prev().find('.tax_subtotal').html(parseInt(total * tax_only).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
			$(this).html(parseInt(total * tax).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
		});

	};


	// Disable default enter functonality and instead perform tab-ish, including skipping to relevant price input on the tanka page
	function checkEnter(e){
		e = e || event;
		var txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
		return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
	}
	if (document.querySelector('form')) {

	};
	// Disable default enter functonality and instead perform tab-ish, including skipping to relevant price input on the tanka page
	function checkEnter(e){
		e = e || event;
		var txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
		return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
	}
	if (document.querySelector('form')) {
		document.querySelector('form').onkeypress = checkEnter;
		$('input').on("keypress", function(e) {
			/* ENTER PRESSED*/
			if (e.keyCode == 13) {
				/* FOCUS ELEMENT */
				var idx = inputs.index(this);
				var warning_inputs = $('input.bg-warning')

				if (warning_inputs.length > 0) {
					var warning_idx = warning_inputs.add(this).index(this) - 1;
					if (warning_idx == warning_inputs.length) { // if it's the last entry select the submit button
						$('.submit').focus();
					} else {
						warning_inputs[warning_idx + 1].focus(); //  handles submit buttons
						warning_inputs[warning_idx + 1].select();
					}
					return false;

				} else {
					// if it's the last entry select the submit button
					$('.submit').focus();
					return false;
				}
			}
		});
	};

	// Make sure all inputs have a 0, select all numbers on focus
	var inputs = $('.genryou').find('input');
	inputs.focusout(function(){
		if ($(this).val() == '') {
			$(this).val("0");
		};
	});
	inputs.focus(function() {
   		$(this).select();
	});
	
});