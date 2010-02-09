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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * PackageListItem
 * @version $Rev: 53092 $
 */
public class UpgradablePackageListItem extends PackageListItem {
    private Long serverId;
    private List errataId = new ArrayList();
    private List errataAdvisory = new ArrayList();
    private List errataAdvisoryType = new ArrayList();;
    private Set installed;
    private String installedPackage = new String();

    /**
     * @return Returns the installed.
     */
    public Set getInstalled() {
        return installed;
    }
    /**
     * @param installedIn The installed to set.
     */
    public void setInstalled(Collection installedIn) {
        this.installed = new HashSet(installedIn);
    }

    /**
     * @return Returns the installed package.
     */
    public String getInstalledPackage() {
        return installedPackage;
    }
    /**
     * @param installedPackageIn The installed package.
     */
    public void setInstalledPackage(String installedPackageIn) {
        this.installedPackage = installedPackageIn;
    }

    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }
    /**
     * @param serverIdIn The serverId to set.
     */
    public void setServerId(Long serverIdIn) {
        serverId = serverIdIn;
    }
    /**
     * @return Returns the evrId.
     */
    public List getErrataId() {
        return errataId;
    }
    /**
     * @param errataIdIn The evrId to set.
     */
    public void setErrataId(List errataIdIn) {
        errataId = errataIdIn;
    }

    /**
     * @return Returns the Errata Advisory.
     */
    public List getErrataAdvisory() {
        return errataAdvisory;
    }
    /**
     * @param errataAdvisoryIn The errata advisory to set.
     */
    public void setErrataAdvisory(List errataAdvisoryIn) {
        errataAdvisory = errataAdvisoryIn;
    }
    /**
     * @return Returns the Errata Advisory Type.
     */
    public List getErrataAdvisoryType() {
        return errataAdvisoryType;
    }
    /**
     * @param errataAdvisoryTypeIn The errata advisory to set.
     */
    public void setErrataAdvisoryType(List errataAdvisoryTypeIn) {
        errataAdvisoryType = errataAdvisoryTypeIn;
    }

    /**
     * Returns the three errata instance variables as
     * a list of HashMaps all in a single convenient Object 
     * @return list of HashMaps with advisory, id, and type keys
     */
    public List getErrata() {
        List retval = new ArrayList();
        for (int i = 0; i < errataAdvisory.size(); i++) {
            Map current = new HashMap();
            current.put("advisory", errataAdvisory.get(i));
            current.put("id", errataId.get(i));
            if (i < errataAdvisoryType.size()) {
                current.put("type", errataAdvisoryType.get(i));    
            }
            retval.add(current);
        }
        return retval;
    }
}
