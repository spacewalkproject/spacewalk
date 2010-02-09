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
package com.redhat.rhn.manager.kickstart.cobbler;

/**
 * 
 * Exception when we didnt setup our token with cobbler.
 * @version $Rev$
 */
public class NoCobblerTokenException extends RuntimeException {

    /**
     * Constructor 
     * @param msg to show user
     */
    public NoCobblerTokenException(String msg) {
        super(msg);
    }

    /**
     * Constructor 
     * @param msg to show user
     * @param e the actual exception 
     */
    public NoCobblerTokenException(String msg, Exception e) {
        super(msg, e);
    }
    
}
