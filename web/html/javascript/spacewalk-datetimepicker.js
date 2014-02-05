/**
 * Helper for DateTimePickerTag JSP tag
 * options:
 *   startDate: preselected date in the picker (Date object)
 */
function setupDatePicker(name, value) {
  $(document).ready(function () {
    // date picker is setup using data attributes

    $('#' + name + '_datepicker_widget_input').datepicker();
    // make the addon clickable
    $('#' + name + '_datepicker_widget_input_addon').click(function() {
      $('#' + name + '_datepicker_widget_input').datepicker('show');
    });

    // initialize the time picker
    var timeFmt = $('#' + name + '_timepicker_widget_input_addon').attr('data-time-format');
    $('#' + name + '_timepicker_widget_input').timepicker({ 'timeFormat': timeFmt });

    // make the addon clickable
    $('#' + name + '_timepicker_widget_input_addon').click(function() {
      $('#' + name + '_timepicker_widget_input').timepicker('show');
    });

    // compatibility with the forms expected by struts
    $('#' + name + '_timepicker_widget_input').on('changeTime', function() {
      var pickerTime = $('#' + name + '_timepicker_widget_input').timepicker('getTime');
      $('input#' + name + '_hour').val(pickerTime.getHours() % 12);
      $('input#' + name + '_minute').val(pickerTime.getMinutes());
      $('input#' + name + '_am_pm').val(pickerTime.getHours() >= 12 ? 1 : 0);
    });

    $('#' + name + '_datepicker_widget_input').datepicker().on('changeDate', function(e) {
      $('input#' + name + '_day').val(e.date.getDate());
      $('input#' + name + '_month').val(e.date.getMonth());
      $('input#' + name + '_year').val(e.date.getFullYear());
    });

    // set initial value and fire events for first time
    $('#' + name + '_datepicker_widget_input').datepicker('setDate', value);
    $('#' + name + '_timepicker_widget_input').timepicker('setTime', value);
  });
}