Event.observe(window, 'load', initialize);

function initialize() {
	Event.observe('bodysize_formula_id', 'change', function(){
		if($('bodysize_formula_id').value == "new_formula") {
			$('new_formula').show();
		}
		else {
			$('new_formula').hide();
		}
	});
}