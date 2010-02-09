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

import org.apache.struts.action.DynaActionForm;

import java.text.DateFormat;
import java.text.DateFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

/**
 * A bean to support date picking in the UI. To add a date picker to a form,
 * add inputs for the year, day, month etc. to the form, and name them with
 * a common prefix; to support a date picker with name <code>date</code>, 
 * you would add inputs with names <code>date_year, date_month, date_day, 
 * date_hour, date_minute, and date_am_pm</code> to the form. All this form
 * variables need to be declared as type <code>java.util.Integer</code>
 * 
 * <p> In your Struts action, you can initialize the form fields with
 * <pre>
 *   Date d = ...;
 *   DynaActionForm dynaForm = ...;
 *   DatePicker p = new DatePicker("date", timeZone, locale, yearDirection);
 *   p.setDate(d);
 *   p.writeForm(dynaForm.getMap());
 * </pre>
 * 
 * <p> Once the form is submitted, you can extract the date with
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
public class DatePicker {
    
    /**
     * Typical form field when dealing with a date picker.
     * @see com.redhat.rhn.frontend.struts.StrutsDelegate
     */
    public static final String USE_DATE = "use_date";
    
    //
    // Names of the subfields for the date picker
    //
    
    public static final String YEAR   = "year";
    public static final String MONTH  = "month";
    public static final String DAY    = "day";
    public static final String HOUR   = "hour";
    public static final String MINUTE = "minute";
    public static final String AM_PM   = "am_pm";
    public static final int YEAR_RANGE_POSITIVE = 0;
    public static final int YEAR_RANGE_NEGATIVE = 1;
    
    private static final int YEAR_RANGE_SIZE = 5;
    private static final Map FIELD_CALENDAR_MAP = new HashMap();
    
    static {
        FIELD_CALENDAR_MAP.put(Boolean.TRUE, makeFieldCalendarMap(true));
        FIELD_CALENDAR_MAP.put(Boolean.FALSE, makeFieldCalendarMap(false));
    }
    
    private String   name;
    private Calendar cal;
    private Locale   locale;
    private boolean  isLatin;
    private boolean  isDayBeforeMonth;
    private DateFormatSymbols dateFormatSymbols;
    private int      currentYear;
    private int yearRangeDirection;
    
    /**
     * Create a new date picker that extracts fields prefixed with 
     * <code>name0 + "_"</code> and works with the given time zone
     * and locale.
     * 
     * @param name0 the prefix for the subfields for the date picker
     * @param tz the timezone in which values are to be interpreted
     * @param locale0 the locale to use
     * @param yearRangeDirection0 direction of the year range to use. 
     * YEAR_RANGE_POSATIVE means the year selection will go from now
     * until YEAR_RANGE_SIZE in the future (2005-2010). YEAR_RANGE_NEGATIVE
     * will include a range from now until YEAR_RANGE_SIZE in the 
     * past (2000 - 2005)
     */
    public DatePicker(String name0, TimeZone tz, Locale locale0, int yearRangeDirection0) {
        name = name0;
        locale = locale0;
        cal = new GregorianCalendar(tz, locale0);
        cal.setLenient(false);
        currentYear = cal.get(Calendar.YEAR);
        analyzeDateFormat();
        yearRangeDirection = yearRangeDirection0;
    }
    
    /**
     * Return <code>true</code> if the locale uses 12 hour time formats
     * with the additional am/pm designation (like certain anglo-saxon countries).
     * A return value of <code>false</code> indicates that the locale uses
     * a 24 hour clock.
     *  
     * @return <code>true</code> if the locale uses 12 hour times with am/pm, 
     * <code>false</code> if it uses a 24 hour clock.
     */
    public boolean isLatin() {
        return isLatin;
    }
    
    /**
     * Return <code>true</code> if in the given locale the day
     * is written before the month, <false> otherwise.
     * @return <code>true</code> if in the given locale the day
     * is written before the month, <false> otherwise.
     */
    public boolean isDayBeforeMonth() {
        return isDayBeforeMonth;
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
     * Return the month, a number from 0 to 12.
     * @return the month, a number from 0 to 12.
     */
    public Integer getMonth() {
        return getField(MONTH);
    }
    
    /**
     * Return the day, a number from 1 to 31.
     * @return the day, a number from 1 to 31.
     */
    public Integer getDay() {
        return getField(DAY);
    }
    
    /**
     * Return the year
     * @return the year
     */
    public Integer getYear() {
        return getField(YEAR);
    }
    
    /**
     * Return the hour, a number between 1 and 11 if {@link #isLatin}
     * is <code>true</code>, and a number from 0 to 23 otherwise.
     * @return the hour, a number between 1 and 11 if {@link #isLatin}
     * is <code>true</code>, and a number from 0 to 23 otherwise.
     */
    public Integer getHour() {
        return getField(HOUR);
    }
    
    /**
     * Return the minute, a number from 0 to 59.
     * @return the minute, a number from 0 to 59.
     */
    public Integer getMinute() {
        return getField(MINUTE);
    }
    
    /**
     * Return <code>0</code> to indicate AM and <code>1</code>
     * to indicate PM.
     * @return <code>0</code> to indicate AM and <code>1</code>
     * to indicate PM.
     */
    public Integer getAmPm() {
        return getField(AM_PM);
    }
    
    /**
     * Set the month.
     * @param v the month, a number from 0 to 11
     */
    public void setMonth(Integer v) {
        setField(MONTH, v);
    }
    
    /**
     * Set the day.
     * @param v the day, a number from 1 to 31
     */
    public void setDay(Integer v) {
        setField(DAY, v);
    }
    
    /**
     * Set the year
     * @param v the year
     */
    public void setYear(Integer v) {
        setField(YEAR, v);
    }
    
    /**
     * Set the hour
     * @param v the hour
     * @see #getHour
     */
    public void setHour(Integer v) {
        setField(HOUR, v);
    }
    
    /**
     * Set the minute
     * @param v the minute, a number from 0 to 59
     */
    public void setMinute(Integer v) {
        setField(MINUTE, v);
    }
    
    /**
     * Set am or pm
     * @param v <code>0</code> to indicate AM and <code>1</code>
     * to indicate PM.
     */
    public void setAmPm(Integer v) {
        setField(AM_PM, v);
    }
    
    /**
     * Get a list of years for display. The list starts with the current
     * year and descends <code>YEAR_RANGE_SIZE</code> years down.
     * @return a list of years for display
     */
    public int[] getYearRange() {
        int[] result = new int[YEAR_RANGE_SIZE];
        for (int i = 0; i < result.length; i++) {
            if (yearRangeDirection == YEAR_RANGE_NEGATIVE) {
                result[i] = currentYear - i;
            } 
            else if (yearRangeDirection == YEAR_RANGE_POSITIVE) {
                result[i] = currentYear + i;
            }
            else {
                throw new IllegalArgumentException("yearRangeDirection isn't set " +
                        "properly: " + yearRangeDirection + 
                        " must be YEAR_RANGE_NEGATIVE or YEAR_RANGE_POSITIVE");
            }
        }
        return result;
    }
    
    /**
     * Get the range of valid hour values, 1 to 11 if {@link #isLatin} is 
     * <code>true</code> and 0 to 23 otherwise.
     * @return the range of valid hour values, 1 to 11 if {@link #isLatin} is 
     * <code>true</code> and 0 to 23 otherwise.
     */
    public int[] getHourRange() {
        int[] result = isLatin() ? new int[12] : new int[24];
        for (int i = 0; i < result.length; i++) {
            result[i] = isLatin() ? i + 1 : i;
        }
        return result;
    }
    
    /**
     * @return The date constructed from the individual field values
     * of this bean instance, or <code>null</code> if the date is invalid.
     */
    public Date getDate() {
        try {
            return cal.getTime();
        } 
        catch (IllegalArgumentException e) {
            // Ignore and return null to indicate invalid date
            return null;
        }
    }

    /**
     * Set the internal date of the picker to <code>date</code>
     * @param date the date to which the internal date should be set to
     */
    public void setDate(Date date) {
        cal.setTime(date);
    }

    /**
     * The calendar underlying this date picker. It will use
     * the timezone and locale that was given to the picker.
     * @return the calendar underlying this picker
     */
    public Calendar getCalendar() {
        return cal;
    }
    
    /**
     * Parse the values in <code>map</code> into the internal date. The 
     * <code>map</code> must map the names of the date widget fields like 
     * <code>date_year</code> etc. to <code>Integer</code> or parsable
     * <code>String</code> values.
     * 
     * If the map does not contain all of the required fields, the default
     * date of now will be used.
     * 
     * @param map a map from date widget field names to <code>Integer</code>
     *            or <code>String</code> values.
     */
    public void readMap(Map map) {
        cal.clear();
        Map fieldCalMap = getFieldCalMap();
        
        //go through and read all of the fields we need.
        for (Iterator i = fieldCalMap.keySet().iterator(); i.hasNext();) {
            String field = (String) i.next();
            Object value = map.get(propertyName(field));
            Integer fieldValue;
            if (value == null) {
                fieldValue = null;
            }
            else if (value instanceof Integer) {
                fieldValue = (Integer)value;
            }
            else if (value instanceof String) {
                fieldValue = new Integer(Integer.parseInt((String)value));
            }
            //this is necessary for reading request parameters.
            else if (value instanceof String[]) {
                String [] s = (String[])value;
                if (s[0] == null) {
                    fieldValue = null;
                }
                else {
                    fieldValue = new Integer(Integer.parseInt(s[0]));
                }
            }
            else {
                throw new IllegalArgumentException("Form contains a date picker field" +
                        " that is the wrong type: " + value.getClass());
            }
            
            if (fieldValue == null) {
                //This means that one of the required fields wasn't found
                //Therefore, we can't really build up a date, so fall back
                // on the default date, now.
                cal.clear();
                setDate(new Date());
                break; //stop looking for the rest of the fields.
            }
            setField(field, fieldValue);
        }
    }
    
    /**
     * Reads the form fields to populate date fields.
     * If a form does not have all of the fields, the inital date
     * will be now.
     * @param form The form containing date picker fields.
     */
    public void readForm(DynaActionForm form) {
        readMap(form.getMap());
    }
    
    /**
     * Write the internal date into <code>map</code>. The 
     * <code>map</code> will map the names of the date widget fields like 
     * <code>date_year</code> etc. to <code>Integer</code> values.
     * 
     * @param map a map from date widget field names to <code>Integer</code> values
     */
    public void writeToMap(Map map) {
        Map fieldCalMap = getFieldCalMap();
        for (Iterator i = fieldCalMap.keySet().iterator(); i.hasNext();) {
            String field = (String) i.next();
            map.put(propertyName(field), getField(field));
        }
    }
    
    /**
     * Write the internal date into <code>form</code>. The 
     * <code>form</code> will map the names of the date widget fields like 
     * <code>date_year</code> etc. to <code>Integer</code> values.
     * 
     * @param form a dyna action form with date widget field names
     *             to <code>Integer</code> values
     */
    public void writeToForm(DynaActionForm form) {
        writeToMap(form.getMap());
    }
    
    /**
     * Return the value of a particular field from the internal date. Note
     * that the value for <code>HOUR</code> will be between <code>0-12</code>
     * if the locale uses a latin date format, and between <code>0-24</code>
     * if it doesn't.
     * 
     * @param field the name of the field, must be one of the constants 
     * defined by this class
     * @return the value in the internal date associated with the field.
     */
    private Integer getField(String field) {
        int calField = getCalField(field);
        try {
            
            //HACK: instituted for UI's that display 1:00 - 12:00 for hours
            //instead of 0:00 - 11:00 like the Java calendar
            int result = cal.get(calField);
            
            if (isLatin() && field.equals(HOUR) && result == 0) {
                return new Integer(12);
            }
            else {
               return new Integer(result);
            }
        } 
        catch (IllegalArgumentException e) {
            // Ignore and return null to indicate invalid date
            return null;
        }
    }
    
    /**
     * Set the value of a <code>field</code> to the given <code>value</code>. Note
     * that setting a field to an invalid value, e.g., setting <code>MONTH</code> to
     * <code>13</code> will not immediately cause an error. To check that the date is
     * still valid, call {@link #getDate}.
     * 
     * @param field the name of the field to set 
     * @param value the value to set for that field
     */
    private void setField(String field, Integer value) {
        int calField = getCalField(field);
        
        //HACK: instituted for UI's that display 1:00 - 12:00 for hours
        //instead of 0:00 - 11:00 like the Java calendar
        if (isLatin() && field.equals(HOUR) && value != null && value.intValue() == 12) {
            cal.set(calField, 0);
        }
        else {
           cal.set(calField, value == null ? -1 : value.intValue());  
        }
        
    }
    
    /**
     * Return date format symbols for the locale associated with this date picker.
     * This method is mainly provided as a conveniece for generating month names 
     * and am/pm designations in the user interface.
     * 
     * @return the date format symbols for the locale associated with this picker
     */
    public DateFormatSymbols getDateFormatSymbols() {
        if (dateFormatSymbols == null) {
            dateFormatSymbols = new DateFormatSymbols(locale);
        }
        return dateFormatSymbols;
    }
    
    private String propertyName(String field) {
        return name + "_" + field;
    }

    private int getCalField(String field) {
        Map fieldCalMap = getFieldCalMap();
        return ((Integer) fieldCalMap.get(field)).intValue();
    }

    private Map getFieldCalMap() {
        return (Map) FIELD_CALENDAR_MAP.get(Boolean.valueOf(isLatin()));
    }

    
    /**
     * @return Returns the yearRangeDirection.
     */
    public int getYearRangeDirection() {
        return yearRangeDirection;
    }

    private void analyzeDateFormat() {
        // HACK: This checks whether the am/pm indicator is
        // in the default date format for this locale
        SimpleDateFormat sdf = 
            (SimpleDateFormat) DateFormat.getDateTimeInstance(DateFormat.SHORT, 
                    DateFormat.SHORT, locale);
        String pattern = sdf.toPattern();
        isLatin = (pattern.indexOf('a') >= 0);
        // HACK: check whether month or date comes first
        isDayBeforeMonth = pattern.indexOf('d') < pattern.indexOf('M');
    }

    private static Map makeFieldCalendarMap(boolean isLatin) {
        HashMap result = new HashMap();
        result.put(YEAR, new Integer(Calendar.YEAR));
        result.put(MONTH, new Integer(Calendar.MONTH));
        result.put(DAY, new Integer(Calendar.DAY_OF_MONTH));
        if (isLatin) {
            result.put(HOUR, new Integer(Calendar.HOUR));
            result.put(AM_PM, new Integer(Calendar.AM_PM));
        } 
        else {
            result.put(HOUR, new Integer(Calendar.HOUR_OF_DAY));
        }
        result.put(MINUTE, new Integer(Calendar.MINUTE));
        return result;
    }

}
