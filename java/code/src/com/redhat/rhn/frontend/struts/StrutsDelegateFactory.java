/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.struts;


/**
 * StrutsDelegateFactory is a factory for StrutsDelegate objects.
 * 
 * @see StrutsDelegate
 * @version $Rev$
 */
public class StrutsDelegateFactory {
    
    private static StrutsDelegateFactory instance = new StrutsDelegateFactory();
    
    /**
     * Returns a StrutsDelegateFactory object.
     * 
     * @return A StrutsDelegateFactory object.
     */
    public static StrutsDelegateFactory getInstance() {
        return instance;
    }

    /**
     * Creates a new factory. Note that by restricting access to the
     * constructor, we gain the flexibility to plug in different factory
     * implementation should the need arise.
     */
    protected StrutsDelegateFactory() {
    }
    
    /**
     * 
     * @return A StrutsDelegate instance
     */
    public StrutsDelegate getStrutsDelegate() {
        return new StrutsDelegateImpl();
    }
}
