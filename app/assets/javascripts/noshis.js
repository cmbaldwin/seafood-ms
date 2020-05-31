$( document ).on('turbolinks:load', function() {
  $(".noshi_type").change(function () {
    if ($('#noshi_ntype_15, #noshi_ntype_16, #noshi_ntype_17').is( ':checked' )) {
      $('#noshi_namae2, #noshi_namae3, #noshi_namae4, #noshi_namae5').prop('readonly', true)
      $('#noshi_namae4, #noshi_namae5').val('')
      $("#noshi_namae").keyup(function () {
        var repeat = $('#noshi_namae').val()
        $('#noshi_namae2, #noshi_namae3').val(repeat)
        $('#noshi_namae4, #noshi_namae5').val('')
      });
    } else {
      $('#noshi_namae4, #noshi_namae5').prop('readonly', false)
    };
    if ($('#noshi_ntype_16').is( ':checked' )) {
      $('#noshi_omotegaki').val('空白')
    };
  });

  $(".noshi_selector").click(function () {
    $('#noshi_omotegaki').val($(this).html())
  }); 

});