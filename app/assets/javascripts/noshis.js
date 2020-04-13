$( document ).on('turbolinks:load', function() {
  $(".noshi_type").change(function () {
    if ($('#noshi_ntype_15').is( ':checked' ) || $('#noshi_ntype_16').is( ':checked' )) {
      $('#noshi_namae4').prop('readonly', true)
      $('#noshi_namae5').prop('readonly', true)
      $('#noshi_namae4').val('')
      $('#noshi_namae5').val('')
    } else {
      $('#noshi_namae4').prop('readonly', false)
      $('#noshi_namae5').prop('readonly', false)
    };
    if ($('#noshi_ntype_16').is( ':checked' )) {
      $('#noshi_omotegaki').val('空白')
    };
  });

  $(".noshi_selector").click(function () {
    $('#noshi_omotegaki').val($(this).html())
  }); 

});