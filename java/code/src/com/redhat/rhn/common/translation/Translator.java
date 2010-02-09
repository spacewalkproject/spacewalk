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

package com.redhat.rhn.common.translation;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Translator The class that actually does the object translations for us.
 *
 * @version $Rev$
 */

public class Translator extends Translations {

    private Translator() {
    }

    /**
     * Translate from from one object type to another.
     * @param have The object to convert
     * @param want The Class to convert to.
     * @return the converted object 
     */ 
    public static Object convert(Object have, Class want) {
        return convert(Translator.class, have, want);
    }

    /**
     * Convert an Integer object into a String
     * @param i the integer to convert
     * @return Returns the string representation of i
     */
    public static String int2String(Integer i) {
        return (i == null) ? "" : i.toString();
    }
    
    /**
     * Convert an Integer object into a list containing the integer
     * @param i The integer to add to the list
     * @return Returns a list containing i
     */
    public static List int2List(Integer i) {
        List list = new ArrayList();
        if (i != null) {
            list.add(i);
        }
        return list;
    }
    
    /**
     * Convert an Integer object to a boolean
     * @param i Integer to check. 1 = true, anything else = false
     * @return Returns the boolean representation of i
     */
    public static boolean int2Boolean(Integer i) {
        return (i == null) ? false : i.equals(new Integer(1)); 
    }

    /**
     * Convert an Long object to a boolean
     * @param i Long to check. 1 = true, anything else = false
     * @return Returns the boolean representation of i
     */
    public static boolean long2Boolean(Long i) {
        return (i == null) ? false : i == 1; 
    }
    
    /** Convert from Integer to User 
     * @param l The Long to convert
     * @return The resulting User
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static User long2User(Integer l) 
        throws Exception {
        return UserFactory.lookupById(new Long(l.longValue()));
    }

    /** Convert from Long to long
     * @param l The Long to convert
     * @return The resulting long
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static long long2Objlong(Long l) 
        throws Exception {
        return (l == null) ? 0 : l.longValue();
    }
    
    /**
     * Converts a Long to an Integer if needed.
     * @param l Long object to be 
     * @return Integer version of the Long.
     */
    public static Integer long2Integer(Long l) {
        return (l == null) ? null : new Integer(l.intValue());
    }
    
    /**
     * Converts a Long to an int if needed.
     * @param l Long object to be 
     * @return int version of the Long.
     */
    public static int long2Int(Long l) {
        return (l == null) ? 0 : l.intValue();
    }

    /** Convert from BigDecimal to int
     * @param bd The BigDecimal to convert
     * @return The resulting int
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static int bigDecimal2Int(BigDecimal bd) 
        throws Exception {
        return (bd == null) ? 0 : bd.intValue();
    }

    /** Convert from BigDecimal to Integer 
     * @param bd The BigDecimal to convert
     * @return The resulting Integer
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static Integer bigDecimal2IntObject(BigDecimal bd) 
        throws Exception {
        return (bd == null) ? new Integer(0) : new Integer(bd.intValue());
    }

    /** Convert from BigDecimal to long
     * @param bd The BigDecimal to convert
     * @return The resulting long
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static long bigDecimal2Long(BigDecimal bd) 
        throws Exception {
        return (bd == null) ? 0 : bd.longValue();
    }

    /** 
     * Convert from BigDecimal to Long 
     * @param bd The BigDecimal to convert
     * @return The resulting Long
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static Long bigDecimal2LongObj(BigDecimal bd)
        throws Exception {
        return (bd == null) ? null : new Long(bd.longValue());
    }

    /** 
     * Convert from String to boolean.
     * @param str The string to convert
     * @return true if the string equals "Y", false otherwise.
     * @throws Exception if anything goes wrong while doing the conversion.
     */
    public static boolean string2boolean(String str) 
        throws Exception {
        if (str == null) {
            return false;
        }
        
        // need to check the possible true values
        // tried to use BooleanUtils, but that didn't
        // get the job done for an integer as a String.
        if (str.equals("1") || str.equalsIgnoreCase("y") ||
                str.equalsIgnoreCase("true")) {
            return true;
        }
        
        return false;
    }
    
    /**
     * Convert from Double to String.
     * @param d The double to convert
     * @return The resulting string.
     */
    public static String double2String(Double d) {
        return (d == null) ? "0" : d.toString();
    }
    
    /**
     * Converts a List to a String
     * @param l list to be converted
     * @return List.toString()
     */
    public static String list2String(List l) {
        return (l == null) ? "" : l.toString();
    }
    
    /**
     * Converts a Map to a String.
     * @param m map to be converted
     * @return map.toString()
     */
    public static String map2String(Map m) {
        return (m == null) ? "" : m.toString();
    }

    /**
     * Convert from Boolean to String.
     * @param b The Boolean to convert
     * @return The resulting string.
     */
    public static String boolean2String(Boolean b) {
        return (b == null) ? Boolean.FALSE.toString() : b.toString();
    }

    /**
     * Convert from Date to String.
     * 
     * @param d Date to convert
     * @return Resulting string
     */
    public static String date2String(Date d) {
        return (d == null) ? "" : d.toString();
    }
    
    /**
     * Convert from a Boolean to a boolean
     * @param b the Boolean to convert
     * @return a boolean primitive 
     */
    public static boolean boolean2boolean(Boolean b) {
        return (b == null) ? false : b.booleanValue();
    }
}
