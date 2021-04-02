var selects = $('#supply_action_partial select')
selects.mouseup(function(event) {
	var options = $(this).find('option')
	// Remove selected from other selects
	var selected = $(this).find('option:selected')
	$.each(selected, function() {
		other_selects_same_option = selects.find(`option[value=${$(this).val()}]`).not('option:selected')
		other_selects_same_option.remove()
	});
	// Add selects back to all selects (if missing) when deselecting
	var unselected = $(this).find('option').not('option:selected')
	$.each(unselected, function(u_i, u_v) {
		deselected_el = $(unselected[u_i])
		deselected_html = `<option value="${deselected_el.val()}">${deselected_el.text()}</option>`
		$.each(selects, function(sl_i, sl_v) {
			deselected = $(sl_v).find(`option[value=${$(u_v).val()}]`)
			if (!deselected.length) {
				$(sl_v).prepend(deselected_html)
			}
		});
	});
	// Re-organize selects options in numerical order after completing the above functions
	$.each(selects, function() {
		option_array = []
		$.each(options, function() {
			option_array.push({
				'html': `<option value="${$(this).val()}">${$(this).text()}</option>`,
				'value': $(this).val()
			})
		});
		sorted_array = option_array.sort((a,b) => a['value'] - b['value'])
		$.each(options, function(o_i, o_v) {
			if (!$(this).is(':selected')) {
				$(this).replaceWith(sorted_array[o_i]['html'])
			};
		});
	});
	// Hide and unhide additional entry sections based on if a selection option is detected
	next_index = selects.index($(this)) + 1
	next_select = selects[next_index]
	next_suppliers_select = $(`#suppliers_select_${next_index}`)
	next_price_select = $(`#suppliers_prices_${next_index}`)
	if ((selected.length > 0) && (next_suppliers_select.length) && ($(next_select).find('option').length)) {
		if (next_suppliers_select.hasClass('d-none')) {
			next_suppliers_select.removeClass('d-none')
		}
		if (next_price_select.hasClass('d-none')) {
			next_price_select.removeClass('d-none')
		}
	} else {
		if (!next_suppliers_select.hasClass('d-none')) {
			next_suppliers_select.addClass('d-none')
		}
		if (!next_price_select.hasClass('d-none')) {
			next_price_select.addClass('d-none')
		}
	}
});