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
package com.redhat.rhn.manager.kickstart;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * IpAddressRange
 * @version $Rev$
 */
public class IpAddressRange {

    private IpAddress min;
    private IpAddress max;
    private Long ksid;

    /**
     * Default Construtor
     *
     */
    public IpAddressRange() {
        this.min = new IpAddress();
        this.max = new IpAddress();
        this.ksid = new Long(0);
    }

    /**
     *
     * @param minIn min IP to set
     * @param maxIn max IP to set
     * @param ksidIn Kickstart ID to set
     */
    public IpAddressRange(IpAddress minIn, IpAddress maxIn, Long ksidIn) {
        this.min = minIn;
        this.max = maxIn;
        this.ksid = ksidIn;
    }

    /**
     *
     * @param minIn IpNumber to set min IpAddress
     * @param maxIn IpNumber to set max IpAddress
     * @param ksidIn Kickstart ID to set
     */
    public IpAddressRange(long minIn, long maxIn, Long ksidIn) {
        this.min = new IpAddress(minIn);
        this.max = new IpAddress(maxIn);
        this.ksid = ksidIn;
    }

    /**
     *
     * @param minIn min ip long coming in
     * @param maxIn max ip long coming in
     * @param ksidIn long id of ks data
     */
    public IpAddressRange(long minIn, long maxIn, long ksidIn) {
        this(minIn, maxIn, new Long(ksidIn));
    }

    /**
     *
     * @param minIn IpNumber to set min IpAddress
     * @param maxIn IpNumber to set max IpAddress
     */
    public IpAddressRange(Long minIn, Long maxIn) {
        this.min = new IpAddress(minIn.longValue());
        this.max = new IpAddress(maxIn.longValue());
        this.ksid = new Long(0);
    }

    /**
     *
     * @return Max IpAddress for this range
     */
    public IpAddress getMax() {
        return this.max;
    }

    /**
     *
     * @param maxIn IpAddress to set for this range
     */
    public void setMax(IpAddress maxIn) {
        this.max = maxIn;
    }

    /**
     *
     * @return min IpAddress for this range
     */
    public IpAddress getMin() {
        return this.min;
    }

    /**
     *
     * @param minIn IpAddress to set for this range
     */
    public void setMin(IpAddress minIn) {
        this.min = minIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (o == null || !(o instanceof IpAddressRange)) {
            return false;
        }
        IpAddressRange other = (IpAddressRange)o;
        return new EqualsBuilder().append(this.getMax(), other.getMax())
                                  .append(this.getMin(), other.getMin())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getMax())
                                    .append(this.getMin())
                                    .toHashCode();
    }

    /**
     *
     * @return Kickstart ID
     */
    public Long getKsid() {
        return ksid;
    }

    /**
     *
     * @param ksidIn KickstartId to set
     */
    public void setKsid(Long ksidIn) {
        this.ksid = ksidIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return getRange();
    }

    /**
     * TODO: does anybody use this? Is there any reason for it to exist?
     * @return range in String form
     */
    public String getRange() {
        return getMin().toString() + " - " + getMax().toString();
    }

    /**
     *
     * @param addrIn Address coming
     * @return is this IPaddress contained in this range
     */
    public boolean isIpAddressContained(IpAddress addrIn) {
        return (addrIn.getNumber() >= this.min.getNumber() &&
                addrIn.getNumber() <= this.max.getNumber());
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return if this range is before the other
     */
    public boolean isRangeBefore(IpAddressRange rangeIn) {
        return (this.max.getNumber() < rangeIn.min.getNumber());
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return if this range is after the other
     */
    public boolean isRangeAfter(IpAddressRange rangeIn) {
        return (this.min.getNumber() > rangeIn.max.getNumber());
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return is this range is disjoint from the other
     */
    public boolean isDisjoint(IpAddressRange rangeIn) {
        return (this.isRangeBefore(rangeIn) || this.isRangeAfter(rangeIn));
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return is this range a subset of the other
     */
    public boolean isSubset(IpAddressRange rangeIn) {
        return (this.min.getNumber() >= rangeIn.min.getNumber() &&
                this.max.getNumber() <= rangeIn.max.getNumber());
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return does this range contain the other range
     */
    public boolean isSuperset(IpAddressRange rangeIn) {
        return (this.min.getNumber() <= rangeIn.min.getNumber() &&
                this.max.getNumber() >= rangeIn.max.getNumber());
    }

    /**
     *
     * @param rangeIn Range coming in
     * @return can this range coexist with other ranges in org
     */
    public boolean canCoexist(IpAddressRange rangeIn) {
        return ((this.isDisjoint(rangeIn) || this.isSubset(rangeIn) ||
                this.isSuperset(rangeIn)) && !this.equals(rangeIn));

    }
}
