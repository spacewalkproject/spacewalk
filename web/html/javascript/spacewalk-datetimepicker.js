/**
 * Helper for DateTimePickerTag JSP tag
 * options:
 *   startDate: preselected date in the picker (Date object)
 */
function setupDatePicker() {
  // date picker is setup using data attributes
  $('input[data-provide="date-picker"]').each(function() {
    var input = $(this);
    input.datepicker();
    var name = input.data('picker-name');
    $('.input-group-addon[data-picker-name="' + name + '"][data-picker-type="date"]').click(function() {
      input.datepicker('show');
    });

    // backward compatibility
    input.datepicker().on('changeDate', function(e) {
      $('input#' + name + '_day').val(e.date.getDate());
      $('input#' + name + '_month').val(e.date.getMonth());
      $('input#' + name + '_year').val(e.date.getFullYear());
    });

    // set initial date if specified
    date = new Date();
    var year = input.data('initial-year');
    if (year != undefined) {
      date.setFullYear(year);
    }
    var month = input.data('initial-month');
    if (month != undefined) {
      date.setMonth(month);
    }
    var day = input.data('initial-day');
    if (day != undefined) {
      date.setDate(day);
    }
    input.datepicker('setDate', date);
  });

  $('input[data-provide="time-picker"]').each(function() {
    var input = $(this);
    var name = input.data('picker-name');

    // initialize the time picker
    var timeOpts = {};

    var timeFmt = input.data('time-format');
    if (timeFmt != undefined) {
      $.extend(timeOpts, {'timeFormat': timeFmt });
    }
    input.timepicker(timeOpts);

    $('.input-group-addon[data-picker-name="' + name + '"][data-picker-type="time"]').click(function() {
      input.timepicker('show');
    });

    // compatibility with the forms expected by struts
    input.on('changeTime', function() {
      var pickerTime = input.timepicker('getTime');
      var am_pm = $('input#' + name + '_am_pm');
      var hour = $('input#' + name + '_hour');
      var isLatin = (am_pm.length != 0);
      if (isLatin) {
        var hVal = pickerTime.getHours() % 12;
        hour.val(hVal == 0 ? 12 : hVal);
      } else {
        hour.val(pickerTime.getHours());
      }
      $('input#' + name + '_minute').val(pickerTime.getMinutes());
      am_pm.val(pickerTime.getHours() >= 12 ? 1 : 0);
    });

    // set initial time
    var date = new Date();
    var hour = input.data('initial-hour');
    if (hour != undefined) {
      date.setHours(hour);
    }
    var minute = input.data('initial-minute');
    if (minute != undefined) {
      date.setMinutes(minute);
    }
    input.timepicker('setTime', date);
  });
}

$(document).ready(function () {
  setupDatePicker();
});