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

import org.apache.commons.lang.StringUtils;

import java.text.DateFormatSymbols;
import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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



    private static final String MONTH = "month";
    private static final String DAY = "day";
    private static final String HOUR = "hour";
    private static final String MINUTE = "minute";

    private static final String STATUS_DISABLED = "disabled";


    //Daily defines
    // 0 %d %d * * *
    private static final String STATUS_DAILY = "daily";
    private static final String DAILY_REGEX = "0 \\d \\d * * *";
    private static final String DAILY_HOUR = "_daily_hour";
    private static final String DAILY_MINUTE = "_daily_minute";


    //Weekly defines
    // 0 %d %d * * %d
    private static final String STATUS_WEEKLY = "weekly";
    private static final String WEEKLY_REGEX = "0 \\d \\d * * \\d";
    private static final String WEEKLY_HOUR = "_weekly_hour";
    private static final String WEEKLY_MINUTE = "_weekly_minute";
    private static final String WEEKLY_DAY_OF_WEEK = "_day_week";

    //Monthly Defines
    // 0 %d %d %d * *
    private static final String STATUS_MONTHLY = "monthly";
    private static final String MONTHLY_REGEX = "0 \\d \\d \\d * *";
    private static final String MONTHLY_HOUR = "_monthly_hour";
    private static final String MONTHLY_MINUTE = "_monthly_minute";
    private static final String MONTHLY_DAY_OF_MONTH = "_day_month";


    private static final String STATUS_CRON = "cron";

    private static final String WHITE_SPACE = "\\s+";

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
            if (tmpStatus.equals(STATUS_DAILY)) {
                String hour = request.getParameter(name + DAILY_HOUR);
                String minute = request.getParameter(name + DAILY_MINUTE);
                p.setCronEntry(buildCron(minute, hour, null, null));

            }
            else if (tmpStatus.equals(STATUS_WEEKLY)) {
                String hour = request.getParameter(name + WEEKLY_HOUR);
                String minute = request.getParameter(name + WEEKLY_MINUTE);
                String day = request.getParameter(name + WEEKLY_DAY_OF_WEEK);
                p.setCronEntry(buildCron(minute, hour, null, day));
            }
            else if (tmpStatus.equals(STATUS_MONTHLY)) {
                String hour = request.getParameter(name + MONTHLY_HOUR);
                String minute = request.getParameter(name + MONTHLY_MINUTE);
                String day = request.getParameter(name + MONTHLY_DAY_OF_MONTH);
                p.setCronEntry(buildCron(minute, hour, day, null));
            }
            else if (tmpStatus.equals(STATUS_CRON)) {
                p.setCronEntry(cronEntry);
            }
        }
        else if (cronEntry != null) {
            if (cronEntry.split(WHITE_SPACE).length < 6) {
                //The Cron Entry is too short
                return null;
            }

            if (matches(cronEntry, DAILY_REGEX)) {
                p.setStatus(STATUS_DAILY);
            }
            else if (matches(cronEntry, WEEKLY_REGEX)) {
                p.setStatus(STATUS_WEEKLY);
            }
            else if (matches(cronEntry, MONTHLY_REGEX)) {
                p.setStatus(STATUS_MONTHLY);
            }
            else {
                p.setStatus(STATUS_CRON);
            }
            p.setCronEntry(cronEntry);
        }


        return p;
    }


    private static String buildCron(String minute, String hour,
                                String dayOfMonth, String dayOfWeek) {
        if (minute == null) {
            minute = "*";
        }
        if (hour == null) {
            hour = "*";
        }
        if (dayOfMonth == null) {
            dayOfMonth = "*";
        }
        if (dayOfWeek == null) {
            dayOfWeek = "*";
        }
        String[] items = {"*", minute, hour, dayOfMonth, "*", dayOfWeek};
        return StringUtils.join(items, " ");
    }

    private static boolean matches(String cronEntry, String pattern) {
        Pattern p = Pattern.compile(pattern);
        Matcher m = p.matcher(cronEntry);
        return m.matches();
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
        return getCronValue(5);
    }

    /**
     * @return Returns the dayOfMonth.
     */
    public String getDayOfMonth() {
        return getCronValue(3);
    }

    /**
     * @return Returns the dayOfMonth String.
     */
    public String getDayOfWeekString() {
        String num = getCronValue(5);
        if (num == null || !StringUtils.isNumeric(num) ||
                getDayNames().length - 1 < Integer.parseInt(num)) {
            return null;
        }
        else {
            return getDayNames()[Integer.parseInt(num)];
        }
    }


    /**
     * Get the hour of the day
     * @return the hour
     */
    public String getHour() {
        return getCronValue(2);
    }

    /**
     * Get the minute of the hour
     * @return the minute
     */
    public String getMinute() {
        return getCronValue(1);
    }

    private String getCronValue(int slot) {
        if (getCronEntry() == null) {
            return null;
        }
        else {
            return getCronEntry().split(WHITE_SPACE)[slot];
        }
    }

}
