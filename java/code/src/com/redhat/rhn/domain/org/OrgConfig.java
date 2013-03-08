/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

package com.redhat.rhn.domain.org;

/*
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.usergroup.UserGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
*/

import com.redhat.rhn.domain.BaseDomainHelper;
import org.apache.log4j.Logger;

/**
 * Class OrgConfig that reflects the DB representation of rhnOrgConfiguration DB table:
 * rhnOrgConfiguration
 */
public class OrgConfig extends BaseDomainHelper {

    protected static Logger log = Logger.getLogger(OrgConfig.class);

    private Long orgId;
    private Org org;
    private boolean stagingContentEnabled;
    private Long crashFileSizelimit;

    /**
     * Gets the current value of org_id
     * @return Returns the value of org_id
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * Sets the value of org_id to new value
     * @param orgIdIn New value for orgId
     */
    protected void setOrgId(Long orgIdIn) {
        orgId = orgIdIn;
    }

    /**
     * @return Returns the stageContentEnabled.
     */
    public boolean isStagingContentEnabled() {
        return stagingContentEnabled;
    }

    /**
     * @return Returns the stageContentEnabled.
     */
/**
    public boolean getStagingContentEnabled() {
        return stagingContentEnabled;
    }
**/

    /**
     * @param stageContentEnabledIn The stageContentEnabled to set.
     */
    public void setStagingContentEnabled(boolean stageContentEnabledIn) {
        stagingContentEnabled = stageContentEnabledIn;
    }

    /**
     * Get the org-wide crash file size limit.
     * @return Returns the org-wide crash file size limit.
     */
    public Long getCrashFileSizelimit() {
        return crashFileSizelimit;
    }

    /**
     * Set the org-wide crash file size limit.
     * @param sizeLimitIn The org-wide crash file size limit to set.
     */
    public void setCrashFileSizelimit(Long sizeLimitIn) {
        crashFileSizelimit = sizeLimitIn;
    }
}
