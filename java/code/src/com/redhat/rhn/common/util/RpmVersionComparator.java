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

import java.util.Comparator;

/**
 * Implement the rpmvercmp function provided by librpm
 * in Java. The comparator operates on two strings that
 * represent an RPM version or release.
 * 
 * <p> This comparator is not perfectly antysymmetric for unequal versions, 
 * but close enough to warrant being a comparator. For examples of asymmetry, 
 * check the test.
 * 
 * @version $Rev$
 */
public class RpmVersionComparator implements Comparator {

    /**
     * {@inheritDoc}
     */
    public int compare(Object o1, Object o2) {
        // This method tries to mimick rpmvercmp.c as 
        // closely as possible; it is deliberately doing things
        // in a more C-like manner
        if (o1 != null && o1.equals(o2)) { 
            return 0;
        }
        
        String str1 = (String) o1;
        String str2 = (String) o2;
        int b1 = 0;
        int b2 = 0;
        
        /* loop through each version segment of str1 and str2 and compare them */
        while (b1 < str1.length() && b2 < str2.length()) {
            b1 = skipNonAlnum(str1, b1);
            b2 = skipNonAlnum(str2, b2);

            /* grab first completely alpha or completely numeric segment */
            /* str1.substring(b1, e1) and str2.substring(b2, e2) will */
            /* contain the segments */
            int e1, e2;
            boolean isnum;
            if (xisdigit(xchar(str1, b1))) {
                e1 = skipDigits(str1, b1);
                e2 = skipDigits(str2, b2);
                isnum = true;
            } 
            else {
                e1 = skipAlpha(str1, b1);
                e2 = skipAlpha(str2, b2);
                isnum = false;
            }
            /* take care of the case where the two version segments are */
            /* different types: one numeric, the other alpha (i.e. empty) */
            if (b1 == e1) {
                return -1;  /* arbitrary */
            }
            if (b2 == e2) {
                return (isnum ? 1 : -1);
            }
            
            if (isnum) {
                b1 = skipZeros(str1, b1, e1);
                b2 = skipZeros(str2, b2, e2);
                
                /* whichever number has more digits wins */
                if (e1 - b1 > e2 - b2) {
                    return 1;
                }
                if (e2 - b2 > e1 - b1) {
                    return -1;
                }
            }
            
            /* compareTo will return which one is greater - even if the two */
            /* segments are alpha or if they are numeric.  don't return  */
            /* if they are equal because there might be more segments to */
            /* compare */
            String seg1 = str1.substring(b1, e1);
            String seg2 = str2.substring(b2, e2);
            int rc = seg1.compareTo(seg2);
            if (rc != 0) {
                return  (rc < 0) ? -1 : 1;
            }
            //  Reinitilize
            b1 = e1;
            b2 = e2;
        }
        /* this catches the case where all numeric and alpha segments have */
        /* compared identically but the segment sepparating characters were */
        /* different */
        if (b1 == str1.length() && b2 == str2.length()) {
            return 0;
        }

        /* whichever version still has characters left over wins */
        if (b1 == str1.length()) {
            return -1; 
        } 
        else {
            return 1;
        }
    }

    private int skipZeros(String s, int b, int e) {
        /* throw away any leading zeros - it's a number, right? */
        while (xchar(s, b) == '0' && b < e) {
            b++;
        }
        return b;
    }

    private int skipDigits(String s, int i) {
        while (i < s.length() && xisdigit(xchar(s, i))) {
            i++;
        }
        return i;
    }

    private int skipAlpha(String s, int i) {
        while (i < s.length() && xisalpha(xchar(s, i))) {
            i++;
        }
        return i;
    }

    private int skipNonAlnum(String s, int i) {
        while (i < s.length() && !xisalnum(xchar(s, i))) {
            i++;
        }
        return i;
    }

    private boolean xisalnum(char c) {
        return xisdigit(c) || xisalpha(c);
    }
    
    private boolean xisdigit(char c) {
        return Character.isDigit(c);
    }
    
    private boolean xisalpha(char c) {
        return Character.isLetter(c);
    }
    
    private char xchar(String s, int i) {
        return (i < s.length() ? s.charAt(i) : '\0');
    }
}
