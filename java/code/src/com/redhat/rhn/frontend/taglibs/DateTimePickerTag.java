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

    @Override
    public void release() {
        this.data = null;
        super.release();
    }

    @Override
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

    @Override
    public int doStartTag() throws JspException {
        return super.doStartTag();
    }

    private HtmlTag createInputAddonTag(String type, String icon) {
        HtmlTag dateAddon = new HtmlTag("span");
        dateAddon.setAttribute("class", "input-group-addon");
        dateAddon.setAttribute("id", data.getName() + "_" +
                type + "picker_widget_input_addon");
        HtmlTag dateAddonIcon = new HtmlTag("span");
        dateAddonIcon.setAttribute("class", icon);
        dateAddon.addBody(dateAddonIcon);
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
    private String toWeirdDateFormat(String format) {
        String ret = format.replaceAll("(M)\\1\\1\\1+", "MM");
        ret = ret.replaceAll("MMM", "M");
        ret = ret.replaceAll("MM", "mm");
        ret = ret.replaceAll("M", "m");
        ret = ret.replaceAll("(E)\\1\\1\\1+", "DD");
        ret = ret.replaceAll("E+", "D");
        ret = ret.replaceAll("(D)\\1+", "dd");
        ret = ret.replaceAll("D", "d");
        ret = ret.replaceAll("(y)\\1\\1\\1+", "yyyy");
        ret = ret.replaceAll("y+", "yy");
        return ret;
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
        String ret = format.replaceAll("(a)+", "a");
        ret = ret.replaceAll("(H)\\1+", "H");
        ret = ret.replaceAll("(H)", "G");

        // k (0-24) not supported, convert to the 0-23 format
        ret = ret.replaceAll("(k)\\1+", "H");
        ret = ret.replaceAll("(k)", "G");
        // K (0-11) not supported, convert to the 1-12 format
        ret = ret.replaceAll("(k)\\1+", "h");
        ret = ret.replaceAll("(k)", "g");

        ret = ret.replaceAll("(h)\\1+", "h");
        ret = ret.replaceAll("(h)", "g");
        ret = ret.replaceAll("(m)+", "i");
        ret = ret.replaceAll("(s)+", "s");

        // ignore others
        ret = ret.replaceAll("(z)+", "");
        ret = ret.replaceAll("(Z)+", "");
        ret = ret.replaceAll("(X)+", "");
        return ret;
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

        HtmlTag row = new HtmlTag("div");
        row.setAttribute("class", "row-0");

        HtmlTag col1 = new HtmlTag("div");
        col1.setAttribute("class", "col-md-7");

        HtmlTag group = new HtmlTag("div");
        group.setAttribute("class", "input-group");
        group.setAttribute("id", data.getName() + "_datepicker_widget");

        HtmlTag dateAddon = createInputAddonTag("date", "fa fa-calendar");

        SimpleDateFormat dateFmt = (SimpleDateFormat)
                DateFormat.getDateInstance(DateFormat.SHORT, data.getLocale());
        SimpleDateFormat timeFmt = (SimpleDateFormat)
                DateFormat.getTimeInstance(DateFormat.SHORT, data.getLocale());

        HtmlTag dateInput = new HtmlTag("input");
        dateInput.setAttribute("data-provide", "date-picker");
        dateInput.setAttribute("data-date-today-highlight", "true");
        dateInput.setAttribute("data-date-autoclose", "true");
        dateInput.setAttribute("data-date-language", data.getLocale().toString());
        dateInput.setAttribute("data-date-format",
                toWeirdDateFormat(dateFmt.toPattern()));
        dateInput.setAttribute("type", "text");
        dateInput.setAttribute("class", "form-control");
        dateInput.setAttribute("id", data.getName() + "_datepicker_widget_input");

        String firstDay = getJavascriptPickerDayIndex(
                data.getCalendar().getFirstDayOfWeek());
        dateInput.setAttribute("data-date-week-start", firstDay);

        HtmlTag timeAddon = createInputAddonTag("time", "fa fa-clock-o");

        HtmlTag timeInput = new HtmlTag("input");
        timeInput.setAttribute("type", "text");
        timeInput.setAttribute("class", "form-control");
        timeInput.setAttribute("data-time-format",
                toPhpTimeFormat(timeFmt.toPattern()));
        timeInput.setAttribute("id", data.getName() + "_timepicker_widget_input");

        HtmlTag tzAddon = new HtmlTag("span");
        tzAddon.setAttribute("id", data.getName() + "_tz_input_addon");
        tzAddon.setAttribute("class", "input-group-addon");
        tzAddon.addBody(
                data.getCalendar().getTimeZone().getDisplayName(
                        false, TimeZone.SHORT, data.getLocale()));

        HtmlTag col2 = new HtmlTag("div");
        col2.setAttribute("class", "col-md-5");

        group.addBody(dateAddon);
        group.addBody(dateInput);
        if (!data.getDisableTime()) {
            group.addBody(timeAddon);
            group.addBody(timeInput);
            group.addBody(tzAddon);
        }

        col1.addBody(group);
        row.addBody(col1);
        row.addBody(col2);

        out.append(row.render());
        // compatibility with the old struts form
        // these values are updated when the picker changes using javascript
        out.append(createHiddenInput("day").render());
        out.append(createHiddenInput("month").render());
        out.append(createHiddenInput("year").render());
        if (!data.getDisableTime()) {
            out.append(createHiddenInput("hour").render());
            out.append(createHiddenInput("minute").render());
            out.append(createHiddenInput("am_pm").render());
        }
    }

    private HtmlTag createHiddenInput(String type) {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("id", data.getName() + "_" + type);
        input.setAttribute("name", data.getName() + "_" + type);
        input.setAttribute("type", "hidden");
        return input;
    }

    private void writePickerJavascript(Writer out) throws IOException {
        writeJavascriptIncludes(out);
        out.append("<script type='text/javascript'>\n");
        out.append("  $(document).ready(function () {\n");
        out.append("    setupDatePicker('" + data.getName() + "', ");
        out.append(String.format("new Date(%d, %d, %d, %d, %d));\n",
                data.getYear(), data.getMonth(), data.getDay(),
                data.getHourOfDay(), data.getMinute()));
        out.append("  });\n");
        out.append("</script>\n");
    }

    private void writeJavascriptIncludes(Writer out) throws IOException {
        if (pageContext.getRequest().getAttribute(JS_INCLUDE_GUARD_ATTR) == null) {
            writeI18NMap(out);
            out.append("<script type='text/javascript' " +
                    "src='/javascript/spacewalk-datetimepicker.js'></script>\n");
            pageContext.getRequest().setAttribute(JS_INCLUDE_GUARD_ATTR, true);
        }
    }

    private void writeI18NMap(Writer out) throws IOException {
        // generate i18n for the picker here
        DateFormatSymbols syms = data.getDateFormatSymbols();
        out.append("<script type='text/javascript'>\n");
        out.append("$.fn.datepicker.dates['" + data.getLocale() + "'] = {\n");
        out.append("days: [ \n");
        out.append(String.format("  '%s'", syms.getWeekdays()[Calendar.SUNDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.MONDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.TUESDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.WEDNESDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.THURSDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.FRIDAY]));
        out.append(String.format(",  '%s'", syms.getWeekdays()[Calendar.SATURDAY]));
        out.append("],\n");
        out.append("daysShort: [ \n");
        Writer buf = new StringWriter();
        buf.append(String.format("  '%s'", syms.getShortWeekdays()[Calendar.SUNDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.MONDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.TUESDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.WEDNESDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.THURSDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.FRIDAY]));
        buf.append(String.format(",  '%s'", syms.getShortWeekdays()[Calendar.SATURDAY]));
        out.append(buf.toString());
        out.append("],\n");
        out.append("daysMin: [ \n");
        out.append(buf.toString());
        out.append("],\n");
        out.append("months: [ \n");
        out.append(String.format("  '%s'", syms.getMonths()[Calendar.JANUARY]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.FEBRUARY]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.MARCH]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.APRIL]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.MAY]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.JUNE]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.JULY]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.AUGUST]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.SEPTEMBER]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.OCTOBER]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.NOVEMBER]));
        out.append(String.format(",  '%s'", syms.getMonths()[Calendar.DECEMBER]));
        out.append("],\n");
        out.append("monthsShort: [ \n");
        out.append(String.format("  '%s'", syms.getShortMonths()[Calendar.JANUARY]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.FEBRUARY]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.MARCH]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.APRIL]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.MAY]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.JUNE]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.JULY]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.AUGUST]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.SEPTEMBER]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.OCTOBER]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.NOVEMBER]));
        out.append(String.format(",  '%s'", syms.getShortMonths()[Calendar.DECEMBER]));
        out.append("]\n");
        out.append("};\n");
        out.append("</script>\n");
    }
}
