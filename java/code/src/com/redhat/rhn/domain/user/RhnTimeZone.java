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
package com.redhat.rhn.domain.user;

import java.util.TimeZone;

/**
 * TimeZone
 * @version $Rev$
 */
public class RhnTimeZone {
    private int timeZoneId;
    private String olsonName;
    private TimeZone timeZone;
    
    /**
     * @return Returns the olsonName.
     */
    public String getOlsonName() {
        return olsonName;
    }
    
    /**
     * @param o The olsonName to set.
     */
    public void setOlsonName(String o) {
        this.olsonName = o;
        if (o != null) {
            timeZone = TimeZone.getTimeZone(o);
        }
    }
    
    /**
     * @return Returns the timeZoneId.
     */
    public int getTimeZoneId() {
        return timeZoneId;
    }
    
    /**
     * @param t The timeZoneId to set.
     */
    public void setTimeZoneId(int t) {
        this.timeZoneId = t;
    }
    
    /**
     * @return Returns the timeZone.
     */
    public TimeZone getTimeZone() {
        return timeZone;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        boolean answer = false;
        if (o instanceof RhnTimeZone) {
            if (this.hashCode() == o.hashCode()) {
                answer = true;
            }
        }
        return answer;
    }

    /**
     * {@inheritDoc}
     */    
    public int hashCode() {
        int result = 17;
        result = 37 * timeZoneId;
        result += 37 * (olsonName == null ? 0 : olsonName.hashCode());
        result += 37 * (timeZone == null ? 0 : timeZone.hashCode());
        return result;
    }
}
