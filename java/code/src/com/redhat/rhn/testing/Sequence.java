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
package com.redhat.rhn.testing;

/**
 * Sequence
 * @version $Rev$
 */
public class Sequence {
    
    private long initialValue;
    
    /**
     * Creates a new sequence
     *
     */
    public Sequence() {
        this(1L);
    }
    
    /**
     * Creates a new sequence
     * 
     * @param startValue The starting value for the sequence
     */
    public Sequence(long startValue) {
        this.initialValue = startValue;
    }
    
    /**
     * Returns the next value in the sequence as a Long.
     * 
     * @return The next value in the sequence as a Long
     */
    public Long nextLong() {
        return new Long(initialValue++);
    }

}
