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
package com.redhat.rhn.frontend.dto;


/**
 * OrgIdWrapper, Used for queries that simply return an org_id.
 * @version $Rev$
 */
public class OrgIdWrapper {

    private Long orgId;

    /**
     * Setter method to be used by DataSource to see the orgId.  This
     * Use toLong() to get the Long version of the orgId.
     * @param bd Long form of OrgId.
     */
    public void setOrgId(Long bd) {
        orgId = bd;
    }

    /**
     *
     * @param bd ID to set
     */
    public void setId(Long bd) {
        orgId = bd;
    }

    /**
     * Returns long, this is a stupid method but used by
     * datasource for backwards compatibility.
     * @return long
     */
    public Long toLong() {
        return orgId;
    }

    /** {@inheritDoc} */
    public String toString() {
        return (orgId == null) ? null : orgId.toString();
    }
}
