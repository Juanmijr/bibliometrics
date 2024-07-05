$(document).ready(function() {

  $('#fecha_publicacion').datepicker({
    format: 'dd/mm/yyyy'
  });

  $('#select_search').change(function() {
    var optionSelected = $(this).val();
    console.log(optionSelected);

    switch(optionSelected) {
      case 'article':
        console.log("ESTOY AQUÍ");
        $('#maxH').hide();
        break;
      case 'author':
      case 'journal':
        $('#maxH').show();
        break;
    }
  });



});


