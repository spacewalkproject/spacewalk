/**
 * Copyright (c) 2014 SUSE
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.html.HtmlTag;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.text.DateFormat;
import java.text.DateFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * &lt;rhn:datepicker data="${picker}"/&gt;
 *
 * Where picker is a com.redhat.rhn.common.util.DatePicker
 *
 * The date-picker.jsp fragment is kept for backwards compatibility
 *
 * It generates backward compatibility input tags with date_hour,
 * date_minutes, date_am_pm...,
 * using Javascript to be backwards compatible with the old tag,
 * so it should work in all pages.
 *
 * The date is displayed in a localized format when the calendar is not open.
 * The calendar is localized using the month names from the DatePicker class
 * and related classes.
 *
 */
public class DateTimePickerTag extends TagSupport {

    private static final String JS_INCLUDE_GUARD_ATTR = "__spacewalk_datepicker_included";

    private DatePicker data;

    /**
     * @return the date picker object for this tag
     * @see com.redhat.rhn.common.util.DatePicker
     */
    public DatePicker getData() {
        return data;
    }

    /**
     * Sets the date picker for this tag
     * @param pData the date picker object
     */
    public void setData(DatePicker pData) {
        this.data = pData;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        this.data = null;
        super.release();
    }

    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
       try {
          writePickerHtml(pageContext.getOut());
          writePickerJavascript(pageContext.getOut());
       }
       catch (IOException e) {
           throw new JspException(e);
       }
       return super.doEndTag();
    }

    /**
     * {@inheritDoc}
     */
    public int doStartTag() throws JspException {
        return super.doStartTag();
    }

    private HtmlTag createInputAddonTag(String type, String icon) {
        HtmlTag dateAddon = new HtmlTag("span");
        dateAddon.setAttribute("class", "input-group-addon text");
        dateAddon.setAttribute("id", data.getName() + "_" +
                type + "picker_widget_input_addon");
        dateAddon.setAttribute("data-picker-name", data.getName());
        dateAddon.setAttribute("data-picker-type", type);
        IconTag dateAddonIcon = new IconTag(icon);
        dateAddon.addBody("&nbsp;");
        dateAddon.addBody(dateAddonIcon.render());
        return dateAddon;
    }

    /**
     * The date picker uses a strange date format.
     * The is a bug open about that:
     * https://github.com/eternicode/bootstrap-datepicker/issues/182
     *
     * @param format a standard format like the one described in
     *   http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
     * @return a format like the one described in
     *   http://bootstrap-datepicker.readthedocs.org/en/latest/options.html
     */
    private String toDatepickerFormat(String format) {
        return format
            .replaceAll("(^|[^M])MM([^M]|$)", "$1mm$2")
            .replaceAll("(^|[^M])M([^M]|$)", "$1m$2")
            .replaceAll("MMMM+", "MM")
            .replaceAll("MMM", "M")
            .replaceAll("DD+", "dd")
            .replaceAll("D", "d")
            .replaceAll("EEEE+", "DD")
            .replaceAll("E+", "D")
            .replaceAll("(^|[^y])y{1,3}([^y]|$)", "$1yy$2")
            .replaceAll("yyyy+", "yyyy");
    }

    /**
     * The time picker uses the PHP time format
     *
     * @param format a standard format like the one described in
     *   http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
     * @return a format like the one described in
     *   http://php.net/manual/en/function.date.php
     *
     */
    private String toPhpTimeFormat(String format) {
        return format
            .replaceAll("a+", "a")
            .replaceAll("(^|[^H])H([^H]|$)", "$1G$2")
            .replaceAll("HH+", "H")
            .replaceAll("(^|[^h])h([^h]|$)", "$1g$2")
            .replaceAll("hh+", "h")
            // k (1-24) not supported, convert to the 0-23 format
            .replaceAll("kk+", "H")
            .replaceAll("k", "G")
            // K (0-11) not supported, convert to the 1-12 format
            .replaceAll("KK+", "h")
            .replaceAll("K", "g")
            .replaceAll("m+", "i")
            .replaceAll("s+", "s")
            // ignore others
            .replaceAll("z+", "")
            .replaceAll("Z+", "")
            .replaceAll("X+", "");
    }

    /**
     * Convert day java.util.Calendar constants
     * to an index usable by the javascript picker.
     *
     * @return the equivalent index for the javascript picker
     */
    private String getJavascriptPickerDayIndex(int calIndex) {
        return String.valueOf(calIndex - 1);
    }

    private void writePickerHtml(Writer out) throws IOException {

        HtmlTag group = new HtmlTag("div");
        group.setAttribute("class", "input-group");
        group.setAttribute("id", data.getName() + "_datepicker_widget");

        if (!data.getDisableDate()) {
            HtmlTag dateAddon = createInputAddonTag("date", "header-calendar");
            group.addBody(dateAddon);

            SimpleDateFormat dateFmt = (SimpleDateFormat)
                    DateFormat.getDateInstance(DateFormat.SHORT, data.getLocale());

            HtmlTag dateInput = new HtmlTag("input");
            dateInput.setAttribute("id", data.getName() + "_datepicker_widget_input");
            dateInput.setAttribute("data-provide", "date-picker");
            dateInput.setAttribute("data-date-today-highlight", "true");
            dateInput.setAttribute("data-date-orientation", "top auto");
            dateInput.setAttribute("data-date-autoclose", "true");
            dateInput.setAttribute("data-date-language", data.getLocale().toString());
            dateInput.setAttribute("data-date-format",
                    toDatepickerFormat(dateFmt.toPattern()));
            dateInput.setAttribute("type", "text");
            dateInput.setAttribute("class", "form-control");
            dateInput.setAttribute("id", data.getName() + "_datepicker_widget_input");
            dateInput.setAttribute("size", "15");

            dateInput.setAttribute("data-picker-name", data.getName());
            dateInput.setAttribute("data-initial-year", String.valueOf(data.getYear()));
            dateInput.setAttribute("data-initial-month", String.valueOf(data.getMonth()));
            dateInput.setAttribute("data-initial-day", String.valueOf(data.getDay()));

            String firstDay = getJavascriptPickerDayIndex(
                    data.getCalendar().getFirstDayOfWeek());
            dateInput.setAttribute("data-date-week-start", firstDay);

            group.addBody(dateInput);
        }

        if (!data.getDisableTime()) {
            HtmlTag timeAddon = createInputAddonTag("time", "header-clock");
            group.addBody(timeAddon);

            SimpleDateFormat timeFmt = (SimpleDateFormat)
                    DateFormat.getTimeInstance(DateFormat.SHORT, data.getLocale());

            HtmlTag timeInput = new HtmlTag("input");
            timeInput.setAttribute("type", "text");
            timeInput.setAttribute("data-provide", "time-picker");
            timeInput.setAttribute("class", "form-control");
            timeInput.setAttribute("data-time-format",
                                         toPhpTimeFormat(timeFmt.toPattern()));
            timeInput.setAttribute("id", data.getName() + "_timepicker_widget_input");
            timeInput.setAttribute("size", "10");

            timeInput.setAttribute("data-picker-name", data.getName());
            timeInput.setAttribute("data-initial-hour", String.valueOf(data.getHour()));
            timeInput.setAttribute("data-initial-minute", String.valueOf(data.getMinute()));

            group.addBody(timeInput);
        }

        HtmlTag tzAddon = new HtmlTag("span");
        tzAddon.setAttribute("id", data.getName() + "_tz_input_addon");
        tzAddon.setAttribute("data-picker-name", data.getName());
        tzAddon.setAttribute("class", "input-group-addon text tz_input_addon");
        tzAddon.addBody(
                data.getCalendar().getTimeZone().getDisplayName(
                        false, TimeZone.SHORT, data.getLocale()));

        group.addBody(tzAddon);
        out.append(group.render());

        // compatibility with the old struts form
        // these values are updated when the picker changes using javascript
        //
        // if you are tempted to not write out these fields in case
        // date or time are disabled for the picker, mind that
        // DatePicker::readMap resets the date to now() if not all fields
        // are present.
        out.append(createHiddenInput("day", String.valueOf(data.getDay())).render());
        out.append(createHiddenInput("month", String.valueOf(data.getMonth())).render());
        out.append(createHiddenInput("year", String.valueOf(data.getYear())).render());

        out.append(createHiddenInput("hour", String.valueOf(data.getHour())).render());
        out.append(createHiddenInput("minute", String.valueOf(data.getMinute())).render());
        out.append(createHiddenInput("am_pm", String.valueOf((data.getHour() > 12) ? 1 : 0)).render());
    }

    private HtmlTag createHiddenInput(String type, String value) {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("id", data.getName() + "_" + type);
        input.setAttribute("name", data.getName() + "_" + type);
        input.setAttribute("type", "hidden");
        input.setAttribute("value", value);
        return input;
    }

    private void writePickerJavascript(Writer out) throws IOException {
        if (pageContext.getRequest().getAttribute(JS_INCLUDE_GUARD_ATTR) == null) {
            writeJavascriptIncludes(out);
            out.append("<script type='text/javascript'>\n");
            writeI18NMap(out);
            pageContext.getRequest().setAttribute(JS_INCLUDE_GUARD_ATTR, true);
            out.append("</script>\n");
        }
    }

    private void writeJavascriptIncludes(Writer out) throws IOException {
        out.append("<script type='text/javascript' " +
                    "src='/javascript/spacewalk-datetimepicker.js'></script>\n");
    }

    private void writeI18NMap(Writer out) throws IOException {
        // generate i18n for the picker here
        DateFormatSymbols syms = data.getDateFormatSymbols();
        out.append("$.fn.datepicker.dates['" + data.getLocale() + "'] = {\n");

        Writer names = new StringWriter();
        Writer shortNames = new StringWriter();
        String[] nameStrings = syms.getWeekdays();
        String[] shortNameStrings = syms.getShortWeekdays();
        for (int i = Calendar.SUNDAY; i <= Calendar.SATURDAY; i++) {
            names.append(String.format(" '%s',", nameStrings[i]));
            shortNames.append(String.format(" '%s',", shortNameStrings[i]));
        }
        out.append("days:      [" + names.toString() + "],\n");
        out.append("daysShort: [" + shortNames.toString() + "],\n");
        out.append("daysMin:   [" + shortNames.toString() + "],\n");

        names = new StringWriter();
        shortNames = new StringWriter();
        nameStrings = syms.getMonths();
        shortNameStrings = syms.getShortMonths();
        for (int i = Calendar.JANUARY; i <= Calendar.DECEMBER; i++) {
            names.append(String.format(" '%s',", nameStrings[i]));
            shortNames.append(String.format(" '%s',", shortNameStrings[i]));
        }
        out.append("months:      [" + names.toString() + "],\n");
        out.append("monthsShort: [" + shortNames.toString() + "],\n");
        out.append("};\n");
    }
}
