/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.common.util;

import com.redhat.rhn.frontend.context.Context;

import java.text.DateFormatSymbols;
import java.util.Calendar;

import javax.servlet.http.HttpServletRequest;

/**
 * A bean to support date picking in the UI. To add a date picker to a form,
 * add inputs for the year, day, month etc. to the form, and name them with
 * a common prefix; to support a date picker with name <code>date</code>, you would add
 * inputs with names <code>date_year, date_month, date_day,
 * date_hour, date_minute, and date_am_pm</code> to the form. All this form
 * variables need to be declared as type <code>java.util.Integer</code>
 *
 * <p>
 * In your Struts action, you can initialize the form fields with
 *
 * <pre>
 *   Date d = ...;
 *   DynaActionForm dynaForm = ...;
 *   DatePicker p = new DatePicker("date", timeZone, locale, yearDirection);
 *   p.setDate(d);
 *   p.writeForm(dynaForm.getMap());
 * </pre>
 *
 * <p>
 * Once the form is submitted, you can extract the date with
 *
 * <pre>
 *   DynaActionForm dynaForm = ...;
 *   DatePicker p = new DatePicker("date", timeZone, locale, yearDirection);
 *   p.readForm(dynaForm.getMap());
 *   Date result = p.getDate();
 *   if ( result == null ) {
 *     ... tell user that date was incorrect ...
 *   }
 * </pre>
 *
 * @version $Rev$
 */
public class RecurringEventPicker {

    /**
     * Typical form field when dealing with a date picker.
     * @see com.redhat.rhn.frontend.struts.StrutsDelegate
     */
    public static final String USE_DATE = "use_date";

    //
    // Names of the subfields for the date picker
    //

    public static final String MONTH = "month";
    public static final String DAY = "day";
    public static final String HOUR = "hour";
    public static final String MINUTE = "minute";
    public static final String AM_PM = "am_pm";

    public static final String STATUS_DISABLED = "disabled";

    // 0 %d %d * * *
    public static final String STATUS_DAILY = "daily";

    // 0 %d %d * * %d
    public static final String STATUS_WEEKLY = "weekly";

    // 0 %d %d %d * *
    public static final String STATUS_MONTHLY = "monthly";
    public static final String STATUS_CRON = "cron";

    private static final Integer[] DAY_NUMBERS = {Calendar.SUNDAY, Calendar.MONDAY,
                                                Calendar.TUESDAY, Calendar.WEDNESDAY,
                                                Calendar.THURSDAY, Calendar.FRIDAY,
                                                Calendar.SATURDAY};


    /**
.------------------- Second (0-59)
|  .---------------- minute (0 - 59)
|  |  .------------- hour (0 - 23)
|  |  |  .---------- day of month (1 - 31)
|  |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
|  |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
|  |  |  |  |  |
*  *  *  *  *  *  command to be executed
     */


    private String name;
    private String status;
    private String cronEntry;
    private String dayOfWeek;
    private String dayOfMonth;


    /**
     * Constructor
     * @param name0 the name
     */
    public RecurringEventPicker(String name0) {
        name = name0;
        status = STATUS_DISABLED;
    }

    /**
     * Return the name of this picker.
     *
     * @return the name of this picker
     */
    public String getName() {
        return name;
    }


    /**
     * while we could just rely on the ordering and numbering of getWeekdays,
     *  I figured it would be best to not rely on the numbers being what we want.
     * @return List of day names in order from Sunday -> Saturday
     */
    public String[] getDayNames() {
        String[] days = DateFormatSymbols.getInstance(
                Context.getCurrentContext().getLocale()).getWeekdays();
        String[] toReturn = new String[7];
        for (int i = 0; i < DAY_NUMBERS.length; i++) {
            toReturn[i] = days[DAY_NUMBERS[i]];
        }
        return toReturn;
    }





    /**
     * Prepopulate the request with the picker
     * @param request the http request
     * @param name the name of the picker
     * @param cronEntry if non-null, will set the picker to this.
     * @return The created picker
     */
    public static RecurringEventPicker prepopulatePicker(
            HttpServletRequest request, String name, String cronEntry) {

        RecurringEventPicker p = new RecurringEventPicker(name);
        request.setAttribute(name, p);

        String tmpStatus = request.getParameter(name + "_status");
        if (tmpStatus  != null) {
            p.setStatus(tmpStatus);
            if (tmpStatus.equals(STATUS_CRON)) {
                p.setCronEntry(request.getParameter(name + "_cron"));
            }
        }


        return p;
    }



    /**
     * @return Returns the status.
     */
    public String getStatus() {
        return status;
    }


    /**
     * @param statusIn The status to set.
     */
    public void setStatus(String statusIn) {
        status = statusIn;
    }


    /**
     * @return Returns the cronEntry.
     */
    public String getCronEntry() {
        return cronEntry;
    }


    /**
     * @param cronEntryIn The cronEntry to set.
     */
    public void setCronEntry(String cronEntryIn) {
        cronEntry = cronEntryIn;
    }


    /**
     * @return Returns the day.
     */
    public String getDayOfWeek() {
        return dayOfWeek;
    }


    /**
     * @param dayIn The day to set.
     */
    public void setDayOfWeek(String dayIn) {
        dayOfWeek = dayIn;
    }


    /**
     * @return Returns the dayOfMonth.
     */
    public String getDayOfMonth() {
        return dayOfMonth;
    }


    /**
     * @param dayOfMonthIn The dayOfMonth to set.
     */
    public void setDayOfMonth(String dayOfMonthIn) {
        dayOfMonth = dayOfMonthIn;
    }


}
