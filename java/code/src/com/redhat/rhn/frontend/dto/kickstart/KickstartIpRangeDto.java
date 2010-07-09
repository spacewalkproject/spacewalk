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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.frontend.dto.BaseDto;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.IpAddressRange;

/**
 * DTO for a com.redhat.rhn.domain.kickstart.KickStartData
 * @version $Rev: 50942 $
 */
public class KickstartIpRangeDto extends BaseDto {

    private Long id;
    private Long orgId;
    private Long min;
    private Long max;
    private String label;
    private IpAddressRange iprange;

    /**
     * Default constructor. uses IpAddressRange for string range output
     *
     */
    public KickstartIpRangeDto() {
        this.id = new Long(0);
        this.orgId = new Long(0);
        this.min = new Long(0);
        this.max = new Long(0);
        this.label = "";
        this.iprange = new IpAddressRange();
    }

    /**
     *
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     *
     * @param idIn ksid to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     *
     * @return max ip range number
     */
    public Long getMax() {
        return this.max;
    }

    /**
     *
     * @param maxIn max ip number to set
     */
    public void setMax(Long maxIn) {
        this.max = maxIn;
        this.iprange.setMax(new IpAddress(maxIn.longValue()));
    }

    /**
     *
     * @return min ip range number
     */
    public Long getMin() {
        return this.min;
    }

    /**
     *
     * @param minIn min ip number to set
     */
    public void setMin(Long minIn) {
        this.min = minIn;
        this.iprange.setMin(new IpAddress(minIn.longValue()));
    }

    /**
     *
     * @return Kickstart profile name
     */
    public String getLabel() {
        return label;
    }

    /**
     *
     * @param labelIn of Kickstart profile to set
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     *
     * @return org id of this kickstart range
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     *
     * @param orgIdIn org id of this kickstart range to set
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }

    /**
     *
     * @return kickstart range object for this kickstart ip range
     */
    public IpAddressRange getIprange() {
        return this.iprange;
    }
}
