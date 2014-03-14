/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.org.usergroup;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.manager.user.UserManager;

import java.util.Set;


/**
 * OrgUserExtGroup
 * @version $Rev$
 */
public class OrgUserExtGroup extends ExtGroup {

    private Set<ServerGroup> serverGroups;

    /**
     * default constructor
     */
    public OrgUserExtGroup() {

    }

    /**
     * constructor
     * @param orgIn organization
     */
    public OrgUserExtGroup(Org orgIn) {
        this.setOrg(orgIn);
    }

    /**
     * @return Returns the serverGroups.
     */
    public Set<ServerGroup> getServerGroups() {
        return serverGroups;
    }

    /**
     * Return serverGroupsName string
     * similar to UserManager.roleNames
     * @return userGroupsName string
     */
    public String getServerGroupsName() {
        return UserManager.serverGroupsName(serverGroups);
    }

    /**
     * @param serverGroupsIn The serverGroups to set.
     */
    public void setServerGroups(Set<ServerGroup> serverGroupsIn) {
        serverGroups = serverGroupsIn;
    }
}
