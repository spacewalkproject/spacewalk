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

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.manager.errata.ErrataManager;

import java.util.Map;

/**
 * ErrataAclHandler
 * @version $Rev$
 */
public class ErrataAclHandler extends BaseHandler implements AclHandler {

    /**
     * Constructor
     */
    public ErrataAclHandler() {
        super();
    }

    /**
     * See if an errata is published
     * @param ctx The contect map
     * @param params Parameters
     * @return Returns true if the errata is published, false otherwise
     */
    public boolean aclErrataIsPublished(Object ctx, String[] params) {
        // Get eid
        Map map = (Map) ctx;
        User user = (User) map.get("user");
        Long eid = getAsLong(map.get("eid"));
        if (eid == null) {
            throw new BadParameterException("Invalid value for eid");
        }
        Errata errata = ErrataManager.lookupErrata(eid, user);

        //return whether or not this errata is published
        return errata.isPublished();
    }
}
