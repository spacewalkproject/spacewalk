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

package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class StringUtilTest extends RhnBaseTestCase {
    public StringUtilTest(final String name) {
        super(name);
    }

    public void testNoChange() {
        String str = "foobar";
        assertEquals(str, StringUtil.beanify(str));
    }

    public void testRemoveWhitespace() {
        String str = "foo_bar";
        assertEquals("fooBar", StringUtil.beanify(str));
    }

    public void testSmartString() {
        assertEquals(1, StringUtil.smartStringToInt("1"));
        assertEquals(2, StringUtil.smartStringToInt("invalidstring", 2));
        assertEquals(3, StringUtil.smartStringToInt("4blah", 3));
    }

    public void testMapReplace() {
        Map replace = new HashMap();
        replace.put("k0", "v0");
        replace.put("k1", "v1");

        assertEquals("foo <a />", StringUtil.replaceTags("foo <a />", replace));
        assertEquals("foo v0", StringUtil.replaceTags("foo <k0 />", replace));
        assertEquals("foo v0 v1", StringUtil.replaceTags("foo <k0 /> <k1 />", replace));
    }
    
    public void testStringToList() {
        String listme = "A B C D E F G";
        List testme = StringUtil.stringToList(listme);
        assertTrue(testme.contains("A")); 
        assertTrue(testme.contains("G")); 
    }

    public void testRandomPasswdShort() throws Exception {
        try {
            StringUtil.makeRandomPassword(4);
        }
        catch (IllegalArgumentException e) {
            // expected exception
        }
        try {
            StringUtil.makeRandomPassword(0);
        }
        catch (IllegalArgumentException e) {
            // expected exception
        }
        try {
            StringUtil.makeRandomPassword(-1);
        }
        catch (IllegalArgumentException e) {
            // expected exception
        }
    }

    public void testRandomPassword() {
        String passwd = StringUtil.makeRandomPassword(16);
        assertEquals(16, passwd.length());
        int i = passwd.length();
        while (i-- > passwd.length() - 5) {
            assertTrue(Character.isDigit(passwd.charAt(i)));
        }
        while (i-- > 0) {
            assertTrue(Character.isLetter(passwd.charAt(i)));
        }
    }

    public void testGetClassName() {
        String expected = "StringUtilTest";
        assertEquals(expected,
            StringUtil.getClassNameNoPackage(this.getClass()));
    }
    
    public void testHtmlifyString() {
        String testMe = null;
        testMe = StringUtil.htmlifyText(testMe);
        assertNull(testMe);
        
        testMe = "http://www.foo.com?foo=10&bar=30";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("<a href=\"http://www.foo.com?foo=10&bar=30\">" +
                "http://www.foo.com?foo=10&amp;bar=30</a>", testMe);
        
        testMe = "https://www.someurl.com";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("<a href=\"https://www.someurl.com\">" +
                "https://www.someurl.com</a>", testMe);
        
        testMe = "\nstring with\n newlines";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("<br/>string with<br/> newlines", testMe);
        
        testMe = "String <strong>with</strong> html & markup tags";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("String &lt;strong&gt;with&lt;/strong&gt; html &amp; markup tags",
                testMe);
        
        testMe = "http://www.urlwithhttpinit.com";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("<a href=\"http://www.urlwithhttpinit.com\">" +
                "http://www.urlwithhttpinit.com</a>", testMe);
        
        testMe = "<i>http://with.tags/around</i>";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("&lt;i&gt;<a href=\"http://with.tags/around\">" +
                "http://with.tags/around</a>&lt;/i&gt;", testMe);
        
        testMe = "https://woohoo.daddy and some <tag> stuff as <well> \n" +
                "http://with.break.after/it\n not too forgot to " +
                "https://test.the.end/case";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("<a href=\"https://woohoo.daddy\">https://woohoo.daddy</a> " +
                "and some &lt;tag&gt; stuff as &lt;well&gt; <br/>" +
                "<a href=\"http://with.break.after/it\">http://with.break.after/it</a>" +
                "<br/> not too forgot to <a href=\"https://test.the.end/case\">" +
                "https://test.the.end/case</a>", testMe);
        
        testMe = "something with \r\nand some other stuff including\nin it as well.";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("something with <br/>and some other" +
                " stuff including<br/>in it as well.", testMe);
        
        testMe = "something \\n and \\r\\n in it";
        testMe = StringUtil.htmlifyText(testMe);
        assertEquals("something <br/> and <br/> in it",
                testMe);

    }

    public void testJoin() {
        String testString;

        List testEmpty = new LinkedList();
        testString = StringUtil.join(", ", testEmpty);
        assertNull(testString);

        List testOne = new LinkedList();
        testOne.add("One");
        testString = StringUtil.join(", ", testOne);
        assertEquals("One", testString);

        List testMany = new LinkedList();
        testMany.add("One");
        testMany.add("Two");
        testMany.add("Three");
        testMany.add("Many");
        testString = StringUtil.join(", ", testMany);
        assertEquals("One, Two, Three, Many", testString);

        testString = StringUtil.join("...", testMany);
        assertEquals("One...Two...Three...Many", testString);
    }
    
    public void testCategorizeTime3() {
        long oneWeek = (1000 * 60 * 60 * 24 * 7);
        long oneDay = (1000 * 60 * 60 * 24);
        long oneHour = (1000 * 60 * 60);
        long oneMinute = (1000 * 60);
        
        // The tests want to know an exact string.
        // If the system we're running on is slow enough, there may (or may not!) be
        // enough time between "now" and "target" to throw off our expectations.
        // "Slop" is a way to let us deal with the (artificial) test-failures
        // this can cause.
        long slop = 500;
        
        long testDate;
        int maxUnit, minUnit;
        String result;

        // 5 weeks 5 days 5 hours and 5 minutes ago
        testDate = System.currentTimeMillis() - 
            (5 * oneWeek + 5 * oneDay + 5 * oneHour + 5 * oneMinute);
        
        maxUnit = StringUtil.WEEKS_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("5 weeks 5 days 5 hours 5 minutes ago", result);
        // 0 weeks 0 days 1 hour ago
        testDate = System.currentTimeMillis() - oneHour;
        maxUnit = StringUtil.WEEKS_UNITS;
        minUnit = StringUtil.HOURS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("0 weeks 0 days 1 hour ago", result);
        // 47 hours and 1 minute ago
        testDate = System.currentTimeMillis() - (47 * oneHour + oneMinute);
        maxUnit = StringUtil.HOURS_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("47 hours 1 minute ago", result);
        // 600 minutes ago
        testDate = System.currentTimeMillis() - (600 * oneMinute);
        maxUnit = StringUtil.MINUTES_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("600 minutes ago", result);
        // 25 days 5 hours ago
        testDate = System.currentTimeMillis() - (25 * oneDay + 5 * oneHour);
        maxUnit = StringUtil.DAYS_UNITS;
        minUnit = StringUtil.HOURS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("25 days 5 hours ago", result);
        
        // 5 weeks 5 days 5 hours and 5 minutes from now
        testDate = System.currentTimeMillis() + 
            (5 * oneWeek + 5 * oneDay + 5 * oneHour + 5 * oneMinute + slop);
        maxUnit = StringUtil.WEEKS_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("5 weeks 5 days 5 hours 5 minutes from now", result);
        // 0 weeks 0 days 1 hour from now
        testDate = System.currentTimeMillis() + (oneHour + slop);
        maxUnit = StringUtil.WEEKS_UNITS;
        minUnit = StringUtil.HOURS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("0 weeks 0 days 1 hour from now", result);
         // 25 days 5 hours from now
        testDate = System.currentTimeMillis() + (25 * oneDay + 5 * oneHour + slop);
        maxUnit = StringUtil.DAYS_UNITS;
        minUnit = StringUtil.HOURS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("25 days 5 hours from now", result);
        // 47 hours and 1 minute from now
        testDate = System.currentTimeMillis() + (47 * oneHour + oneMinute + slop);
        maxUnit = StringUtil.HOURS_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("47 hours 1 minute from now", result);
        // 600 minutes from now
        testDate = System.currentTimeMillis() + (600 * oneMinute + slop);
        maxUnit = StringUtil.MINUTES_UNITS;
        minUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals("600 minutes from now", result);
    }
    
    public void testCategorizeTime2() {
        long oneWeek = (1000 * 60 * 60 * 24 * 7);
        long oneDay = (1000 * 60 * 60 * 24);
        long oneHour = (1000 * 60 * 60);
        long oneMinute = (1000 * 60);
        
        long testDate;
        int maxUnit;
        String result;

        // 5 weeks 5 days 5 hours and 5 minutes ago
        testDate = System.currentTimeMillis() - 
            (5 * oneWeek + 5 * oneDay + 5 * oneHour + 5 * oneMinute);
        
        maxUnit = StringUtil.WEEKS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("6 weeks ago", result);
        
        // 10 sec ago
        testDate = System.currentTimeMillis() - (20 * 1000);
        maxUnit = StringUtil.WEEKS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("20 seconds ago", result);
        
        // 1 minute ago
        testDate = System.currentTimeMillis() - oneMinute;
        maxUnit = StringUtil.WEEKS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("1 minute ago", result);
        
        // 0 weeks 0 days 1 hour ago
        testDate = System.currentTimeMillis() - oneHour;
        maxUnit = StringUtil.WEEKS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("1 hour ago", result);
        
        // 47 hours and 1 minute ago
        testDate = System.currentTimeMillis() - (47 * oneHour + oneMinute);
        maxUnit = StringUtil.HOURS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("47 hours ago", result);
        
        // 600 minutes ago
        testDate = System.currentTimeMillis() - (600 * oneMinute);
        maxUnit = StringUtil.MINUTES_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("600 minutes ago", result);
        
        // 25 days 5 hours ago
        testDate = System.currentTimeMillis() - (25 * oneDay + 5 * oneHour);
        maxUnit = StringUtil.DAYS_UNITS;
        result = StringUtil.categorizeTime(testDate, maxUnit);
        assertEquals("25 days ago", result);
    }
    
    public void testCategorizeTimeWeekAndYear() {
        long oneDay = (1000 * 60 * 60 * 24);
        long oneWeek = oneDay * 7;
        long oneMonth = oneWeek * 4;
        long oneYear = oneMonth * 12;    
        // 5 weeks 5 days 5 hours and 5 minutes ago
        long testDate = System.currentTimeMillis() - (5 * oneYear + 5 * oneWeek);
        
        checkTime(testDate, 
                       StringUtil.YEARS_UNITS, 
                       StringUtil.WEEKS_UNITS,
                       "5 years 1 month 1 week ago");
        
        checkTime(testDate, 
                    StringUtil.YEARS_UNITS, 
                    StringUtil.MONTHS_UNITS,
                    "5 years 1 month ago");
        
        checkTime(testDate, 
                    StringUtil.MONTHS_UNITS, 
                    StringUtil.DAYS_UNITS,
                    "61 months 1 week 0 days ago");
        
        testDate = System.currentTimeMillis() - 
                            (5 * oneYear + 5 * oneDay);
        checkTime(testDate, 
                    StringUtil.MONTHS_UNITS,
                    StringUtil.WEEKS_UNITS,
                    "60 months 0 weeks ago");        
     }
    
    public void checkTime(long testDate,
                                int maxUnit, 
                                int minUnit,
                                String expected) {
        String result = StringUtil.categorizeTime(testDate, maxUnit, minUnit);
        assertEquals(expected, result);
    }

    public void checkTime(long testDate,
            int maxUnit,
            String expected) {
            String result = StringUtil.categorizeTime(testDate, maxUnit);
            assertEquals(expected, result);
    }
    
    
    public void testWebTolinux() {
        String webstr = "abc\r\ndef\r\n";
        String lstr = "abc\ndef\n";
        assertEquals(lstr, StringUtil.webToLinux(webstr));
    }
    
    public void testDeBeanifyString() {
        String camel = "someBeanFieldNameWithCamelCase";
        String returned = StringUtil.debeanify(camel);
        assertEquals("some_bean_field_name_with_camel_case", returned);
        assertEquals(camel, StringUtil.beanify(returned));
        
    }
    
    public void testToPlainText() {
        String inp = "<p>You donot have enough entitlements for <strong>" +
                    "<a href=\"http://www.redhat.com\">xyz system</a> </strong>.</p>";

        String expected = "You donot have enough entitlements for" +
                                    " xyz system (http://www.redhat.com).";
        assertEquals(expected, StringUtil.toPlainText(inp));
    }
}
