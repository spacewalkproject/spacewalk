/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.xml.utils.XMLChar;
import org.stringtree.json.JSONReader;
import org.stringtree.json.JSONWriter;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorException;

/**
 * A simple class that assists with String manipulation
 * @version $Rev$
 */
public class StringUtil {

    /**
     * Script check errors.
     */
    public enum ScriptCheckResult {
        NO_SHELL_DEFINED(1, "stringutil.scriptcheck.error.noshelldefined"),
        NO_SCRIPT_DEFINED(2, "stringutil.scriptcheck.error.noscript");

        private final int id;
        private final String messageKey;

        ScriptCheckResult(int msgId,
                          String message) {
            this.id = msgId;
            this.messageKey = message;
        }


        /**
         * Get error ID.
         * @return int Return check restult ID.
         */
        public int getId() {
            return id;
        }


        /**
         * Get message key.
         * @return string Returns message key for the translation.
         */
        public String getMessageKey() {
            return messageKey;
        }
    }


    /** time-interval formatting selectors */
    public static final int SECONDS_UNITS = 0;
    public static final int MINUTES_UNITS = 1;
    public static final int HOURS_UNITS = 2;
    public static final int DAYS_UNITS = 3;
    public static final int WEEKS_UNITS = 4;
    public static final int MONTHS_UNITS = 5;
    public static final int YEARS_UNITS = 6;

    // Millis-per-time-unit; used by interval-formatting.
    // Index matches one of the _UNITS above - MUST BE KEPT IN SYNCH
    static final long[] MILLIS_PER_UNIT = { 1000, 60000, 3600000, 86400000, 604800000,
            2419200000L, 29030400000L };
    // Time-unit in next-higher unit (ie, 60 secs in 1 minute); used by
    // interval-formatting.
    // Index matches _UNITS - MUST BE KEPT IN SYNCH
    static final long[] UNITS_PER_NEXT = { 60, 60, 24, 7, 4, 12 };

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(StringUtil.class);

    /**
     * Private constructore
     */
    private StringUtil() {
    }

    /**
     * Convert the passed in string to a valid java method name. This basically
     * capitalizes each word and removes all word delimiters.
     * @param strIn The string to convert
     * @return The converted string
     */
    public static String beanify(String strIn) {
        String str = strIn.trim();
        StringBuilder result = new StringBuilder(str.length());
        boolean wasWhitespace = false;

        for (int i = 0, j = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                if (wasWhitespace) {
                    c = Character.toUpperCase(c);
                    wasWhitespace = false;
                }
                result.insert(j, c);
                j++;
                continue;
            }
            wasWhitespace = true;
        }
        return result.toString();
    }

    /**
     * Convert the passed in bean style string to a underscore separated string.
     *
     * For example: someFieldName -> some_field_name
     *
     * @param strIn The string to convert
     * @return The converted string
     */
    public static String debeanify(String strIn) {
        String str = strIn.trim();
        StringBuilder result = new StringBuilder(str.length());

        for (int i = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (Character.isUpperCase(c)) {
                result.append("_");
            }
            result.append(Character.toLowerCase(c));
        }
        return result.toString();
    }

    /**
     * Converts the passed in string to a valid java Class name. This basically
     * capitalizes each word and removes all word delimiters.
     * @param strIn The string to convert.
     * @return The converted string.
     */
    public static String classify(String strIn) {
        String str = strIn.trim();
        StringBuilder result = new StringBuilder(str.length());
        boolean wasWhitespace = false;

        for (int i = 0, j = 0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (Character.isLetterOrDigit(c)) {
                if (i == 0) {
                    c = Character.toUpperCase(c);
                }
                if (wasWhitespace) {
                    c = Character.toUpperCase(c);
                    wasWhitespace = false;
                }
                result.insert(j, c);
                j++;
                continue;
            }
            wasWhitespace = true;
        }
        return result.toString();
    }

    /**
     * given a string, return the int of it; any parse error results in 0 being
     * returned
     * @param s the String to convert
     * @return int the String converted to an int type
     */

    public static int smartStringToInt(String s) {
        return smartStringToInt(s, 0);
    }

    /**
     * given a string, return the int of it; any parse error results in default
     * being returned
     * @param s the String to convert
     * @param defaultValue the default value to assign to the return value if
     * the String didn't parse correctly
     * @return int the String converted to an int type
     */
    public static int smartStringToInt(String s, int defaultValue) {
        int ret;
        try {
            ret = Integer.parseInt(s);
        }
        catch (NumberFormatException nfe) {
            ret = defaultValue;
        }

        return ret;
    }

    /**
     * given a string and a map, all instances of {key} will be replaced with
     * the value of 'key' in the map. so for example, "this is a {noun}" with a
     * Map that has ("noun" => "fish") would produce "this is a fish"
     * @param source the source string to be replaced
     * @param params the parameters to fill out the source string with
     * @return String Replaced String
     */
    public static String replaceTags(String source, Map<String, String> params) {
        String ret = source;
        Iterator<Map.Entry<String, String>> i = params.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry<String, String> me = i.next();
            ret = StringUtils.replace(ret, "<" + me.getKey() + " />", me.getValue()
                    .toString());
        }

        return ret;
    }

    /**
     * Using {@link java.util.StringTokenizer}, stringToList will convert the
     * string to a list of individual strings based on the standard default
     * StringTokenizer behavior. {@link java.util.StringTokenizer} <BR>
     * For example:<BR>
     * <BR>
     * "AAA BBB CCC DDD EEE FFF" <BR>
     * would be converted to a list containing:<BR>
     * {"AAA", "BBB", "CCC", "DDD", "EEE", "FFF"}<BR>
     * <BR>
     *
     * @param convertIn convert this string to a list
     * @return List version of specified string
     * @todo This should be removed and replaced with a call like:
     * Arrays.toList(str.split(","), String[]);
     */
    public static List<String> stringToList(String convertIn) {
        StringTokenizer st = new StringTokenizer(convertIn);
        List<String> retval = new LinkedList<String>();
        while (st.hasMoreTokens()) {
            retval.add(st.nextToken());
        }
        return retval;
    }

    /**
     * Create a random password of the specified length
     * @param lengthIn length of random password
     * @return String new random password
     */
    public static String makeRandomPassword(int lengthIn) {
        if (lengthIn < 5) {
            throw new IllegalArgumentException("Length too short");
        }
        StringBuilder sb = new StringBuilder(lengthIn);
        Random rand = new Random();
        int length = lengthIn;
        while (length-- > 5) {
            sb.append((char) ('A' + rand.nextInt(26)));
        }

        while (length-- >= 0) {
            sb.append((char) ('0' + rand.nextInt(10)));
        }
        return sb.toString();
    }

    /**
     * Convert a class's name into the name without the package For example
     * StringUtils.getClassNameNoPackage(StringUtils.class) outputs: StringUtils
     * @param clazz The Class we want to get the name of
     * @return String name of the class without the package
     */
    public static String getClassNameNoPackage(final Class clazz) {
        String fullyQualifiedClassName = clazz.getName();
        int idx = fullyQualifiedClassName.lastIndexOf('.');
        return fullyQualifiedClassName.substring(idx + 1);
    }

    /**
     * Returns a String for html parsing escapes html converts \n to a break tag
     * (&lt;BR/&lt;) converts urls beginning with http:// and https:// to links
     * Example: given http://foo.bar/example return <a
     * href="http://foo.bar/example">http://foo.bar/example</a>
     * @param convertIn the String we want to convert
     * @return html version of the String
     * @see org.apache.commons.lang.StringEscapeUtils
     */
    public static String htmlifyText(String convertIn) {
        if (convertIn == null) {
            return null;
        }
        if (logger.isDebugEnabled()) {
            logger.debug("htmlifyText() - " + convertIn);
        }
        String retval = StringEscapeUtils.escapeHtml(convertIn);
        retval = retval.replaceAll("\\\\r\\\\n", "<br/>");
        retval = retval.replaceAll("\\\\n", "<br/>");
        retval = retval.replaceAll("\r\n", "<br/>");
        retval = retval.replaceAll("\n", "<br/>");

        Pattern startUrl = Pattern.compile("https?://"); // http:// or https://
        Matcher next = startUrl.matcher(retval);
        boolean done = false;
        int previous = 0; // the starting index of the previously found url
        List<String> pieces = new LinkedList<String>();

        /*
         * Separates the string into a list. Break points for different tokens
         * in the list are the start of each hyperlink (http:// or https://).
         * Basically, this finds the start of each piece we need to modify
         */
        while (!done) {
            if (next.find()) {
                pieces.add(retval.substring(previous, next.start()));
                previous = next.start();
            }
            else {
                pieces.add(retval.substring(previous));
                done = true;
            }
        }

        /*
         * Adds each piece of the list back to the string modifying each that
         * starts with http:// or https:// This part finds the end of each url
         * and executes modifications
         */
        Iterator<String> itr = pieces.iterator();
        StringBuilder result = new StringBuilder();
        while (itr.hasNext()) {
            String current = itr.next();
            Matcher match = startUrl.matcher(current);
            if (match.find()) { // if this is a url
                int end = findEndOfUrl(current);
                StringBuilder modify = new StringBuilder("<a href=\"");
                if (end != -1) { // if the end of the url is not the end of the
                                 // token
                    modify.append(current.substring(0, end).replaceAll("&amp;", "&"));
                    modify.append("\">");
                    modify.append(current.substring(0, end));
                    modify.append("</a>");
                    modify.append(current.substring(end));
                }
                else { // if the end of the url is the end of the token
                    modify.append(current.substring(0).replaceAll("&amp;", "&"));
                    modify.append("\">");
                    modify.append(current.substring(0));
                    modify.append("</a>");
                }
                current = modify.toString();
            }
            result.append(current);
        }

        if (logger.isDebugEnabled()) {
            logger.debug("htmlifyText() - returning: " + result);
        }

        return result.toString();
    }

    /**
     * Join the strings contained in inputList with the separator. Returns null
     * if the input list is empty
     *
     * @param separator The String to glue the strings in inputList together
     * with
     * @param inputList The List of Strings to join
     * @return The joined String
     */
    public static String join(String separator, Collection<String> inputList) {
        Iterator<String> itty = inputList.iterator();

        return join(separator, itty);
    }

    /**
     * Join the strings contained in an iterator with a separator. Used by
     * join(String,List) and acts as a convenience for the few times we want to
     * use join without a list.
     * @param separator The String separator, use
     * <code>Localization.getInstance().getMessage("list delimiter")</code> for
     * the appropriate display separator.
     * @param itty The iterator containing display items.
     * @return The joined String
     */
    public static String join(String separator, Iterator<String> itty) {
        if (!itty.hasNext()) {
            return null;
        }

        StringBuilder ret = new StringBuilder();
        ret.append(itty.next());

        while (itty.hasNext()) {
            ret.append(separator);
            ret.append(itty.next());
        }

        return ret.toString();
    }

    /**
     * Finds end of URL.
     * @param entireToken input String (URL)
     * @return position of last char of URL, returns -1 when entire String is URL
     */
    private static int findEndOfUrl(String entireToken) {
        int space = entireToken.indexOf(' ');
        int line = entireToken.indexOf("<br/>");
        int tag = entireToken.indexOf("&lt;");
        int end = -1;

        // end characters
        Set<Character> endChars = new HashSet<Character>();
        endChars.add(new Character('.'));
        endChars.add(new Character(','));

        if (space == -1 || (space > line && line != -1)) {
            end = line;
        }
        else {
            end = space;
        }

        if (end == -1 || (end > tag && tag != -1)) {
            end = tag;
        }

        // dot before the end
        if (end > 0 && (endChars.contains(
                new Character(entireToken.charAt(end - 1))))) {
            end--;
        }
        // dot at the end
        else if (endChars.contains(
                new Character(entireToken.charAt(entireToken.length() - 1)))) {
            end = entireToken.length() - 1;
        }

        return end;
    }

    /**
     * Converts the number of bytes to the appropriate unit (B, KB, or MB)
     * depending on how many bytes there actually are. It then localizes the
     * display of this number and formats the display with the units. It will
     * return fractional units for larger numbers (123.45 Mb and 123.4 Kb)
     * @param bytes the number of bytes used by a file
     * @return A localized and formatted string displaying the file size
     */
    public static String displayFileSize(long bytes) {
        return displayFileSize(bytes, false);
    }

    /**
     * Converts the number of bytes to the appropriate unit (B, KB, or MB)
     * depending on how many bytes there actually are. It then localizes the
     * display of this number and formats the display with the units. It will
     * return fractional units for larger numbers (123.45 Mb and 123.4 Kb)
     * unless wholeNum == true.
     * @param bytes the number of bytes used by a file
     * @param wholeNum should the result be returned as a whole number?
     * @return A localized and formatted string displaying the file size
     */
    public static String displayFileSize(long bytes, boolean wholeNum) {
        LocalizationService ls = LocalizationService.getInstance();
        String number = null;
        String type = null;
        if (bytes >= (1024 * 1024)) { // show in megabytes (with two decimals)
            number = ls.formatNumber(new Double(bytes / (1024.0 * 1024)),
                    (wholeNum ? 0 : 2));
            type = "mb";
        }
        else if (bytes >= 1024) { // show in kilobytes (with one decimal)
            number = ls.formatNumber(new Double(bytes / 1024.0), (wholeNum ? 0 : 1));
            type = "kb";
        }
        else { // show in bytes (with no decimals)
            number = ls.formatNumber(new Long(bytes), 0);
            type = "b";
        }

        /*
         * the number that has now been localized is being used as an argument
         * for another localization call. I'm not really sure if the format of
         * displaying file sizes is truly something that needs to be localized.
         */
        return ls.getMessage("file_size." + type, number);
    }

    private static void checkUnits(int maxUnit, int minUnit) {
        if (maxUnit < 0 || maxUnit > YEARS_UNITS) {
            throw new IllegalArgumentException("maxUnit out of range");
        }
        if (minUnit < 0 || minUnit > YEARS_UNITS) {
            throw new IllegalArgumentException("minUnit out of range");
        }
        if (maxUnit < minUnit) {
            throw new IllegalArgumentException("maxUnit must be >= minUnit!");
        }
    }

    /**
     * Takes a target time (in msecs) and a maximum and minimum
     * time-unit-of-interest and returns an I18N string in
     * "x [maxUnits] y [units] ... z [minUnits] [ago:from now]" format.
     *
     * @param target timestamp in msecs-since-epoch of the event
     * @param maxUnit constant representing the maximum unit you want to
     * display.
     * @param minUnit constant representing the minimum unit you want to
     * display.
     * @return I18N string in "x [maxUnits] y [units] ... z [minUnits] [ago:from
     * now] format
     * @throws IllegalArgumentException if maxUnit or minUnit not recognized, or
     * if maxUnit < minUnit
     */
    public static String categorizeTime(long target, int maxUnit, int minUnit) {
        checkUnits(maxUnit, minUnit);
        long now = System.currentTimeMillis();
        long elapsedTime = (now > target ? (now - target) : (target - now));

        // Start by filling an array with the number of "whole units"
        // for each of the units requested, from max to min.
        // NOTE: this whole process works only because the MILLIS_PER_UNIT
        // and UNITS_PER_NEXT arrays are in synch wit hthe _UNIT specifiers.
        long[] unitValues = new long[MILLIS_PER_UNIT.length];
        for (int currUnit = maxUnit; currUnit >= minUnit; currUnit--) {
            if (currUnit == maxUnit) {
                unitValues[currUnit] = elapsedTime / MILLIS_PER_UNIT[currUnit];
            }
            else {
                elapsedTime -= (unitValues[currUnit + 1] * MILLIS_PER_UNIT[currUnit + 1]);
                unitValues[currUnit] = elapsedTime / MILLIS_PER_UNIT[currUnit];
            }
        }

        // Now, localize the unit-strings for each unit requested
        StringBuilder buff = new StringBuilder();
        for (int currUnit = maxUnit; currUnit >= minUnit; currUnit--) {
            buff = buff.append(localizeUnit(unitValues[currUnit], currUnit)).append(" ");
        }

        // Now, localize the whole message and return it
        LocalizationService ls = LocalizationService.getInstance();
        return ls.getMessage("timetag.categorizeLongFormat", buff.toString().trim(),
                getTense(now, target));
    }

    // Return the "n <unit(s)>" string for the specified unit and n
    private static String localizeUnit(long interval, int unit) {
        LocalizationService ls = LocalizationService.getInstance();
        String unitString = getUnitString(unit, interval);
        return ls.getMessage("timetag.oneunit", interval, unitString);
    }

    /**
     * Takes a target time (in msecs) and a time-unit-of-interest and returns an
     * I18N string in "x {units} {ago:from now}" format.
     *
     * @param target timestamp in msecs-since-epoch of the event
     * @param maxUnit constant representing the unit you want to display. The
     * code will "back off" from that to show the largest non-zero unit needed
     * to represent the time-difference
     * @return I18N string in "x {units} {ago:from now}" format
     * @throws IllegalArgumentException if maxUnit not recognized
     */
    public static String categorizeTime(long target, int maxUnit) {
        checkUnits(maxUnit, maxUnit);
        long remainder;
        long valInMaxUnits;

        long now = System.currentTimeMillis();
        long elapsedTime = (now > target ? (now - target) : (target - now));
        int theUnit = findMaximumUnitFor(elapsedTime, maxUnit);

        // maxUnit is now one of entered-value,
        // largest-unit-smaller-than-elapsed,
        // or SECONDS_UNITS. Figure out how-many units we have, and what the
        // remainder is
        valInMaxUnits = elapsedTime / MILLIS_PER_UNIT[theUnit];
        remainder = elapsedTime % MILLIS_PER_UNIT[theUnit];

        // If the remainder > half a unit, round up.
        // Note: we don't round seconds
        if (theUnit != SECONDS_UNITS &&
                remainder >= (MILLIS_PER_UNIT[theUnit - 1] *
                        (UNITS_PER_NEXT[theUnit - 1] / 2))) {
            valInMaxUnits++;
        }

        // Now we have all the pieces - return the localized string
        LocalizationService ls = LocalizationService.getInstance();
        String unitString = getUnitString(theUnit, valInMaxUnits);
        String tense = getTense(now, target);
        return ls.getMessage("timetag.categorizeFormat", valInMaxUnits, unitString, tense);
    }

    // What's the biggest unit <= specified elapsed time?
    private static int findMaximumUnitFor(long elapsed, int specifiedMax) {
        // Find max units < elapsed time
        int theUnit = specifiedMax;
        while (elapsed < MILLIS_PER_UNIT[theUnit] && theUnit > SECONDS_UNITS) {
            theUnit--;
        }
        return theUnit;
    }

    // What's the i18n string for the specified unit.
    // Handles 1-vs-many
    private static String getUnitString(int unit, long val) {
        LocalizationService ls = LocalizationService.getInstance();
        switch (unit) {
        case SECONDS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.second");
            }
            return ls.getMessage("timetag.seconds");
        case MINUTES_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.minute");
            }
            return ls.getMessage("timetag.minutes");
        case HOURS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.hour");
            }
            return ls.getMessage("timetag.hours");
        case DAYS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.day");
            }
            return ls.getMessage("timetag.days");
        case WEEKS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.week");
            }
            return ls.getMessage("timetag.weeks");
        case MONTHS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.month");
            }
            return ls.getMessage("timetag.months");
        case YEARS_UNITS:
            if (val == 1) {
                return ls.getMessage("timetag.year");
            }
            return ls.getMessage("timetag.years");

        default:
            return ls.getMessage("timetag.unknown");
        }
    }

    // Is Target in the past or the future?
    private static String getTense(long now, long target) {
        LocalizationService ls = LocalizationService.getInstance();
        if (now < target) {
            return ls.getMessage("timetag.futuretense");
        }
        return ls.getMessage("timetag.pasttense");
    }

    /**
     * Convert an incoming web-string (with \r\n EOL) to a Linux string (with \n
     * as EOL)
     * @param inWebStr string from a web form
     * @return Linux-EOL'd-string TODO: This shoudl be generalized to handle
     * other kinds of non-Linux EOLs, so we can use it on uploaded files as well
     */
    public static String webToLinux(String inWebStr) {
        return (inWebStr == null ? null : inWebStr.replaceAll("\r\n", "\n"));
    }

    /**
     * Encode a string for use in a URL.
     * @param source Source string to encode.
     * @return Encoded version of source.
     */
    public static String urlEncode(String source) {
        String encodedParam = null;
        try {
            encodedParam = URLEncoder.encode(source, "UTF-8");
        }
        catch (Exception e) {
            encodedParam = URLEncoder.encode(source);
        }
        return encodedParam;
    }

    /**
     * Basically turns an html or xml snippet to plain text Meant to be used
     * along with string resources xml file messages. This is a best guess plain
     * text conversion.. For example the following text
     *
     * <pre>
     * &lt;p&gt;You donot have enough entitlements for &lt;strong&gt;
     *                   xyz system &lt;/strong&gt;&lt;/p&gt;
     * will get converted to
     * You donot have enough entitlements for xyz system
     * It just returns the original snippet back in the case
     * of an xml error (however it throws a warning)...
     * &#064;param html the html/xml String resources snippet to convert
     * @param html html input
     * @return the plain text version.
     */
    public static String toPlainText(String html) {
        XmlToPlainText helper = new XmlToPlainText();
        return helper.convert(html);
    }

    /**
     * Converts an object to json representation
     * @param obj any object
     * @return the jsoned representation
     */
    public static String toJson(Object obj) {
        JSONWriter writer = new JSONWriter();
        return writer.write(obj);
    }

    /**
     * Converts a jsoned representation back to the object
     * @param json json string
     * @return the converted object.. The caller is expected to know the kind of
     * returned object.
     */
    public static Object jsonToObject(String json) {
        JSONReader reader = new JSONReader();
        return reader.read(json);
    }

    /**
     * Convert a string of options (name value pairs separated by '=', where the
     * pairs are seperated by 'separator'), into a map.
     * @param options the string of options
     * @param errorKey the localization key of the error message to throw if we
     * can't parse it correctly
     * @param separator the separator the separates different name value pairs
     * @return a map containing name value pairs of options
     * @throws ValidatorException if there isn't an '=' sign seperating the
     * pairs
     */
    public static Map<String, String> convertOptionsToMap(String options, String errorKey,
                                                                String separator)
        throws ValidatorException {
        Map<String, String> toReturn = new HashMap<String, String>();
        StringTokenizer token = new StringTokenizer(options, separator);
        while (token.hasMoreElements()) {
            String option = token.nextToken();
            if (!StringUtils.isBlank(option)) { //Skip blank lines
                String[] args = option.split("=", 2);
                if (args.length != 2) {
                    ValidatorException.raiseException(errorKey, option);
                }
                else {
                    toReturn.put(args[0], args[1].trim());
                }
            }
        }
        return toReturn;
    }

    /**
     * Convert a map of kernel options into a string: name1=value1 name2=value2
     * name3=value
     * @param map the map of options
     * @param seperator the seperator to seperate the pairs with
     * @return the formatted string
     */
    public static String convertMapToString(Map<String, Object> map, String seperator) {

        StringBuilder string = new StringBuilder();
        for (Object key : map.keySet()) {
            string.append(key + "=" + map.get(key) + seperator);
        }
        return string.toString();
    }

    /**
     * Add a path onto another path.
     * This ensures double '/'s aren't included
     * @param originalPath The start of the path
     * @param toAdd what to add
     * @return the full path with no duplicate '/'s
     */
    public static String addPath(String originalPath, String toAdd) {
        return new File(originalPath, toAdd).getPath();
    }

    /**
     *
     * @param b The byteArray of the compressedDigest stream
     * @return the hexString equivalent
     */
    public static String getHexString(byte[] b) {
        String result = "";
        for (int i = 0; i < b.length; i++) {
            result += Integer.toString((b[i] & 0xff) + 0x100, 16).substring(1);
        }
        return result;
    }


    /**
     * Checks, whether string contains invalid xml chars
     * @param string to check
     * @return true if there're xml invalid chars
     */
    public static Boolean containsInvalidXmlChars2(String string) {
        for (int i = 0; i < string.length(); i++) {
            if (!XMLChar.isValid(string.charAt(i))) {
                return Boolean.TRUE;
            }
        }
        return Boolean.FALSE;
    }

    /**
     * Tests String byte-length and eventually truncates
     * @param str input String
     * @param length target length
     * @return truncated String
     */
    public static String getBytesTruncatedString(String str, int length) {
        try {
            byte[] bytes = str.getBytes("UTF-8");
            if (bytes.length > length) {
                return new String(Arrays.copyOf(bytes, length), "UTF-8");
            }
        }
        catch (UnsupportedEncodingException e) {
            logger.warn("Unable to convert to UTF-8 bytes.");
        }
        return str;
    }


    /**
     * Returns null, if string is empty, is already null or contains tabs, whitespace,
     * line breaks or other non-valuable content. It also matches Unicode characters.
     * @param str string
     * @return null if empty (see description), original string otherwise.
     */
    public static String nullOrValue(String str) {
        return (str == null ? "" : str)
                   .trim()
                   .replaceAll("[^\\p{L}\\p{Nd}]", "")
                   .isEmpty() ? null : str;
    }

    /**
     * Returns null, if string is empty
     * @param str string
     * @return null if empty, original string otherwise
     */
    public static String nullIfEmpty(String str) {
        return StringUtils.isBlank(str) ? null : str;
    }


    /**
     * Check if the script seems to be valid.
     * @param script Script body
     * @return null if no errors, otherwise result enum with the error code.
     */
    public static ScriptCheckResult scriptPrematureCheck(String script) {
        ScriptCheckResult result = null; // Assume the script is valid.
        if (StringUtil.nullOrValue(script) == null) {
            result = ScriptCheckResult.NO_SCRIPT_DEFINED;
        }
        else {
            boolean hasShellDeclaration = false;
            int codeLines = 0;

            String[] lines = script.split(System.getProperty("line.separator"));
            for (int i = 0; i < lines.length; i++) {
                String line = StringUtil.nullOrValue(lines[i]);
                if (line != null) {
                    line = line.trim();
                    if (line.startsWith("#!/") && !hasShellDeclaration) {
                        hasShellDeclaration = true;
                    }
                    else if (!line.startsWith("#")) {
                        codeLines++;
                    }
                }
            }

            if (codeLines == 0) {
                result = ScriptCheckResult.NO_SCRIPT_DEFINED;
            }
            else if (!hasShellDeclaration) {
                result = ScriptCheckResult.NO_SHELL_DEFINED;
            }
        }

        return result;
    }
}
