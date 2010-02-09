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
package com.redhat.rhn.frontend.servlets;



/**
 * PxtSessionDelegateFactory is a factory class for creating PxtSessionDelegate objects.
 * 
 * @see PxtSessionDelegate
 * @version $Rev$
 */
public class PxtSessionDelegateFactory {

    /**
     * Returns a factory object that can create PxtSessionDelegate objects.
     * 
     * @return A factory object that can create PxtSessionDelegate objects.
     */
    public static PxtSessionDelegateFactory getInstance() {
        return new PxtSessionDelegateFactory();
    }
    
    /**
     * This constructor should <strong>not</strong> be called by clients. Clients should
     * use {@link #getInstance()} to obtain a factory. The constructor has protected
     * visibility to allow for different factory implementations through subclassing.
     */
    protected PxtSessionDelegateFactory() {
    }
    
    /**
     * Returns an instance of PxtSessionDelegate.
     * 
     * @return An instance of PxtSessionDelegate
     */
    public PxtSessionDelegate newPxtSessionDelegate() {
        return new PxtSessionDelegateImpl();
    }
}
