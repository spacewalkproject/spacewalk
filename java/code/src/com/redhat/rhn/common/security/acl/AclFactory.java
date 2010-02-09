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

package com.redhat.rhn.common.security.acl;

import org.apache.commons.lang.StringUtils;

/**
 * Class to assist with creating Acls.  This Factory will setup 
 * the Acl class as well as setup the default as well as the mixin AclHandlers 
 * associated with the Acl.
 * 
 * TODO - consider caching the Acl instances within the Factory so we don't have to
 * instantiate new ones each time. Not sure how to do this yet.
 * 
 * @version $Rev$
 */
public class AclFactory {

    // private instance of the service.
    private static AclFactory instance = new AclFactory();

    /**
     * hidden constructor
     */
    private AclFactory() {
        // hidden constructor
    }
    
    /** Get the running instance of the AclFactory
     *
     * @return The AclFactory singleton
     */
    public static AclFactory getInstance() {
        return instance;
    }
    
    /** 
     * Get an instance of an Acl 
     * @param mixinsIn the String with a comma separated list of classnames
     * @return Acl created 
     */
    public Acl getAcl(String mixinsIn) {
        Acl aclObj = new Acl();
        Access access = new Access();
        aclObj.registerHandler(access);

        // Add the mixin handlers as well.
        if (mixinsIn != null) {
            String[] mixin = StringUtils.split(mixinsIn, ",");
            for (int i = 0; i < mixin.length; i++) {
                aclObj.registerHandler(StringUtils.trim(mixin[i]));
            }
        }        
        return aclObj;
    }

}
