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

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * ChannelOverview
 * @version $Rev$
 */
public class ChannelOverview extends BaseDto implements Comparable {
    private Long id;
    private Long orgId;
    private String name;
    private String label;
    private Long relevantPackages;
    private Long originalId;
    private List<PackageDto> packages = new ArrayList<PackageDto>();

    /**
     * @return Returns the originalId.
     */
    public Long getOriginalId() {
        return originalId;
    }


    /**
     * @param originalIdIn The originalId to set.
     */
    public void setOriginalId(Long originalIdIn) {
        this.originalId = originalIdIn;
    }

    /** Default no-arg constructor
     */
    public ChannelOverview() {
    }

    /**
     * Constructor with name and id
     * @param nameIn to set
     * @param idIn to set
     */
    public ChannelOverview(String nameIn, Long idIn) {
        this.name = nameIn;
        this.id = idIn;
    }

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
     * Returns the org ID for this channel overview. Note this is only used for some
     * queries and may be returned as null.
     * @return Returns the orgId.
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdIn The org id to set.
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
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
        this.name = nameIn;
    }

    /**
     * @return Returns the channel family label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Returns the relevantPackages.
     */
    public Long getRelevantPackages() {
        return relevantPackages;
    }

    /**
     * @param r The relevantPackages to set.
     */
    public void setRelevantPackages(Long r) {
        this.relevantPackages = r;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("name", name)
                .toString();
    }

    /**
     *
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
           return getName().compareTo(((ChannelOverview) o).getName());
    }

    /**
     * @return Returns the packages.
     */
    public List<PackageDto> getPackages() {
        return packages;
    }

    /**
     * @param packagesIn The packages to set.
     */
    public void setPackages(List<PackageDto> packagesIn) {
        this.packages = packagesIn;
    }
}
