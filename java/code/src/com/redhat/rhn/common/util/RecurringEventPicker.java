/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import java.util.Locale;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

/**
 * The RecurringEventPicker
 *
 * to use this simply add this to your jsp:
 *
 *     <jsp:include page="/WEB-INF/pages/common/fragments/repeat-task-picker.jspf">
 *       <jsp:param name="widget" value="date"/>
 *     </jsp:include>
 *
 *
 *     Then in your action, simply do:
 *
 *       RecurringEventPicker picker = RecurringEventPicker.prepopulatePicker(
 *               request, "date", oldCronExpr);
 *       call picker.getCronExpr() to get the given cron expression (if submitted)
 *       call picker.isDisabled() to see if it is disabled or not
 *
 *
 * @version $Rev$
 */
public class RecurringEventPicker {

    private static final String STATUS_DISABLED = "disabled";

    //Daily defines
    // 0 %d %d * * *
    private static final String STATUS_DAILY = "daily";
    private static final String DAILY_REGEX = "0 +\\d+ +\\d+ +\\? +\\* +\\*";
    private static final String DAILY_HOUR = "_daily_hour";
    private static final String DAILY_MINUTE = "_daily_minute";

    //Weekly defines
    // 0 %d %d * * %d
    private static final String STATUS_WEEKLY = "weekly";
    private static final String WEEKLY_REGEX = "0 +\\d+ +\\d+ +\\? +\\* +\\d";
    private static final String WEEKLY_HOUR = "_weekly_hour";
    private static final String WEEKLY_MINUTE = "_weekly_minute";
    private static final String WEEKLY_DAY_OF_WEEK = "_day_week";

    //Monthly Defines
    // 0 %d %d %d * *
    private static final String STATUS_MONTHLY = "monthly";
    private static final String MONTHLY_REGEX = "0 +\\d+ +\\d+ +\\d+ +\\* +\\?";
    private static final String MONTHLY_HOUR = "_monthly_hour";
    private static final String MONTHLY_MINUTE = "_monthly_minute";
    private static final String MONTHLY_DAY_OF_MONTH = "_day_month";

    private static final String STATUS_CRON = "cron";
    private static final String CRON_ENTRY = "_cron";

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

    private final String name;
    private String status;
    private String cronEntry;

    private final DatePicker dailyTimePicker;
    private final DatePicker weeklyTimePicker;
    private final DatePicker monthlyTimePicker;

    /**
     * Constructor
     * @param name0 the name
     */
    public RecurringEventPicker(String name0) {
        name = name0;
        status = STATUS_DISABLED;
        dailyTimePicker = new DatePicker(name + "_" + STATUS_DAILY,
                TimeZone.getDefault(), Locale.getDefault(),
                DatePicker.YEAR_RANGE_POSITIVE);
        dailyTimePicker.setDisableDate();
        weeklyTimePicker = new DatePicker(name + "_" + STATUS_WEEKLY,
                TimeZone.getDefault(), Locale.getDefault(),
                DatePicker.YEAR_RANGE_POSITIVE);
        weeklyTimePicker.setDisableDate();
        monthlyTimePicker = new DatePicker(name + "_" + STATUS_MONTHLY,
                TimeZone.getDefault(), Locale.getDefault(),
                DatePicker.YEAR_RANGE_POSITIVE);
        monthlyTimePicker.setDisableDate();
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
                DatePicker timePicker = p.getDailyTimePicker();
                timePicker.readMap(request.getParameterMap());
                String hour = String.valueOf(timePicker.getHourOfDay());
                String minute = String.valueOf(timePicker.getMinute());
                p.setCronEntry(buildCron(minute, hour, null, null, STATUS_DAILY));

            }
            else if (tmpStatus.equals(STATUS_WEEKLY)) {
                DatePicker timePicker = p.getWeeklyTimePicker();
                timePicker.readMap(request.getParameterMap());
                String hour = String.valueOf(timePicker.getHourOfDay());
                String minute = String.valueOf(timePicker.getMinute());
                String day = request.getParameter(name + WEEKLY_DAY_OF_WEEK);
                p.setCronEntry(buildCron(minute, hour, null, day, STATUS_WEEKLY));
            }
            else if (tmpStatus.equals(STATUS_MONTHLY)) {
                DatePicker timePicker = p.getMonthlyTimePicker();
                timePicker.readMap(request.getParameterMap());
                String hour = String.valueOf(timePicker.getHourOfDay());
                String minute = String.valueOf(timePicker.getMinute());
                String day = request.getParameter(name + MONTHLY_DAY_OF_MONTH);
                p.setCronEntry(buildCron(minute, hour, day, null, STATUS_MONTHLY));
            }
            else if (tmpStatus.equals(STATUS_CRON)) {
                p.setCronEntry(request.getParameter(name + CRON_ENTRY));
            }
            else if (tmpStatus.equals(STATUS_DISABLED)) {
                p.setStatus(STATUS_DISABLED);
            }
        }
        else if (cronEntry != null) {
            if (cronEntry.split(WHITE_SPACE).length < 6) {
                //The Cron Entry is too short
                return null;
            }

            // here do it the other way around, set the time pickers from
            // the cron time
            if (matches(cronEntry, DAILY_REGEX)) {
                p.setStatus(STATUS_DAILY);
                p.setCronEntry(cronEntry);
                DatePicker timePicker = p.getDailyTimePicker();
                timePicker.setHourOfDay(p.getHourLong().intValue());
                timePicker.setMinute(p.getMinuteLong().intValue());
            }
            else if (matches(cronEntry, WEEKLY_REGEX)) {
                p.setStatus(STATUS_WEEKLY);
                p.setCronEntry(cronEntry);
                DatePicker timePicker = p.getWeeklyTimePicker();
                timePicker.setHourOfDay(p.getHourLong().intValue());
                timePicker.setMinute(p.getMinuteLong().intValue());
            }
            else if (matches(cronEntry, MONTHLY_REGEX)) {
                p.setStatus(STATUS_MONTHLY);
                p.setCronEntry(cronEntry);
                DatePicker timePicker = p.getMonthlyTimePicker();
                timePicker.setHourOfDay(p.getHourLong().intValue());
                timePicker.setMinute(p.getMinuteLong().intValue());
            }
            else {
                p.setStatus(STATUS_CRON);
                p.setCronEntry(cronEntry);
            }
        }

        return p;
    }


    private static String buildCron(String minute, String hour,
                                String dayOfMonth, String dayOfWeek, String type) {

        if (type.equals(STATUS_DAILY)) {
            //0 %d %d ? * *
            String[] items = {"0", minute, hour, "?", "*", "*"};
            return StringUtils.join(items, " ");
        }
        else if (type.equals(STATUS_WEEKLY)) {
            //0 %d %d ? * %d
            String[] items = {"0", minute, hour, "?", "*", dayOfWeek};
            return StringUtils.join(items, " ");
        }
        else if (type.equals(STATUS_MONTHLY)) {
            //0 %d %d %d * ?
            String[] items = {"0", minute, hour, dayOfMonth, "*", "?"};
            return StringUtils.join(items, " ");
        }
        else {
            return "";
        }
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
     * @return Returns the dayOfMonth.
     */
    public Long getDayOfMonthLong() {
        String st  = getCronValue(3);
        if (StringUtils.isNumeric(st)) {
            return Long.parseLong(st);
        }
        return -1L;
    }


    /**
     * @return Returns the dayOfMonth String.
     */
    public String getDayOfWeekString() {
        String num = getCronValue(5);
        if (num == null || !StringUtils.isNumeric(num) ||
                getDayNames().length  < Integer.parseInt(num) ||
                Integer.parseInt(num) < 1) {
            return null;
        }
        return getDayNames()[Integer.parseInt(num) - 1];
    }


    /**
     * Get the hour of the day
     * @return the hour
     */
    public String getHour() {
        return getCronValue(2);
    }

    /**
     * Get the hour of the day
     * @return the hour
     */
    public Long getHourLong() {
        String st  = getCronValue(2);
        if (StringUtils.isNumeric(st)) {
            return Long.parseLong(st);
        }
        return -1L;
    }


    /**
     * Get the minute of the hour
     * @return the minute
     */
    public String getMinute() {
        return getCronValue(1);
    }

    /**
     * Get the hour of the day
     * @return the hour
     */
    public Long getMinuteLong() {
        String st  = getCronValue(1);
        if (StringUtils.isNumeric(st)) {
            return Long.parseLong(st);
        }
        return -1L;
    }


    private String getCronValue(int slot) {
        if (getCronEntry() == null) {
            return null;
        }
        String[] array = getCronEntry().split(WHITE_SPACE);
        if (slot >= array.length) {
            return null;
        }
        return array[slot];
    }

    /**
     * is the picker disabled.
     * @return if it is disabled or not
     */
    public boolean isDisabled() {
        return status.equals(STATUS_DISABLED);
    }

    /**
     * @return a date picker used to select the
     * daily time
     */
    public DatePicker getDailyTimePicker() {
        return dailyTimePicker;
    }

    /**
     * @return a date picker used to select the
     * weekly time
     */
    public DatePicker getWeeklyTimePicker() {
        return weeklyTimePicker;
    }

    /**
     * @return a date picker used to select the
     * monthly time
     */
    public DatePicker getMonthlyTimePicker() {
        return monthlyTimePicker;
    }
}
