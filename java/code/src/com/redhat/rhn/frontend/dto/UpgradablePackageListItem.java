/**
 * Copyright (c) 2008 Red Hat, Inc.
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
public class UpgradablePackageListItem extends IdComboDto {
    private Long id;
    private String idCombo;
    private Long serverId;
    private List errataId;
    private Long nameId;
    private Long evrId;
    private String nvre;
    private String name;
    private String version;
    private String release;
    private String epoch;
    private List errataAdvisory;
    private List errataAdvisoryType;
    private Set installed;

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
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
     * @return Returns the epoch.
     */
    public String getEpoch() {
        return epoch;
    }
    /**
     * @param epochIn The epoch to set.
     */
    public void setEpoch(String epochIn) {
        epoch = epochIn;
    }
    /**
     * @return Returns the evrId.
     */
    public Long getEvrId() {
        return evrId;
    }
    /**
     * @param evrIdIn The evrId to set.
     */
    public void setEvrId(Long evrIdIn) {
        evrId = evrIdIn;
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
     * @return Returns the idCombo.
     */
    public String getIdCombo() {
        return idCombo;
    }
    /**
     * {@inheritDoc}
     */
    public Long getIdOne() {
        return new Long(idCombo.substring(0, idCombo.indexOf("|")));
    }
    /**
     * {@inheritDoc}
     */
    public Long getIdTwo() {
        return new Long(idCombo.substring(idCombo.indexOf("|") + 1));
    }
    /**
     * @param idComboIn The idCombo to set.
     */
    public void setIdCombo(String idComboIn) {
        idCombo = idComboIn;
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
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }
    /**
     * @return Returns the nameId.
     */
    public Long getNameId() {
        return nameId;
    }
    /**
     * @param nameIdIn The nameId to set.
     */
    public void setNameId(Long nameIdIn) {
        nameId = nameIdIn;
    }
    /**
     * @return Returns the nvre.
     */
    public String getNvre() {
        return nvre;
    }
    /**
     * @param nvreIn The nvre to set.
     */
    public void setNvre(String nvreIn) {
        nvre = nvreIn;
    }
    /**
     * @return Returns the release.
     */
    public String getRelease() {
        return release;
    }
    /**
     * @param releaseIn The release to set.
     */
    public void setRelease(String releaseIn) {
        release = releaseIn;
    }
    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }
    /**
     * @param versionIn The version to set.
     */
    public void setVersion(String versionIn) {
        version = versionIn;
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
            current.put("type", errataAdvisoryType.get(i));
            retval.add(current);
        }
        return retval;
    }
}
