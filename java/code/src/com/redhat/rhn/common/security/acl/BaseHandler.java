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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.org.OrgEntitlementType;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;

/**
 * BaseHandler is the base class for all Acl handlers and should
 * be where we put common reusable methods.
 * @version $Rev$
 */
public abstract class BaseHandler implements AclHandler {

    /**
     *
     */
    public BaseHandler() {
        super();
    }

    protected boolean checkMonitoring(User user) {
        OrgEntitlementType monType = new OrgEntitlementType("rhn_monitor");
        boolean retval = (user.getOrg().hasEntitlement(monType) &&
                Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND));
        return retval;
    }


    /**
     * returns true if satellite, false if spacewalk
     * @param ctx Our current context, containing a crid or cfid.
     * @param params nothing
     * @return true if satellite, false if spacewalk
     */
    public boolean aclIsSatellite(Object ctx, String[] params) {
        return !ConfigDefaults.get().isSpacewalk();
    }


    /**
     * Returns a Long object from the given object.  We expect
     * a String[] or String as the input all others return null;
     * @param o object to be converted
     * @return Long if object is parsable, or null.
     */
    public Long getAsLong(Object o) {
        Long ret = null;

        if (o != null) {
            if (o instanceof String[]) {
                String[] s = (String[])o;
                if (s.length > 0 && !StringUtils.isEmpty(s[0])) {
                    ret = new Long(s[0]);
                }
            }
            else if (o instanceof String) {
                String s = (String)o;
                if (!StringUtils.isEmpty(s)) {
                    ret = new Long(s);
                }
            }
            else if (o instanceof Long) {
                ret = (Long) o;
            }
        }

        return ret;
    }
}
