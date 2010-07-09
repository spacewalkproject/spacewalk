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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.frontend.dto.BaseDto;

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;

/**
 * TimeSeriesData - DTO version of table "time_series"
 *
 * @version $Rev: 50942 $
 */
public class TimeSeriesData extends BaseDto {

    private String oid;
    private Float data;
    private Date time;
    private String metric;

    /**
     * Create a new TimeSeriesData record with default values
     * @param oidIn oid for this record (the id)
     * @param dataIn data we want to represent
     * @param timeIn time we want to indicate for the data
     * @param metricIn metric for this TSD
     */
    public TimeSeriesData(String oidIn, Float dataIn, Date timeIn, String metricIn) {
        this.oid = oidIn;
        this.data = dataIn;
        this.time = timeIn;
        this.metric = metricIn;
    }

    /**
     * Returns NULL
     * @return Long null for this type of record.
     */
    public Long getId() {
        return null;
    }

    /**
     * @return Returns the data.
     */
    public Float getData() {
        return data;
    }
    /**
     * @param dataIn The data to set.
     */
    public void setData(Float dataIn) {
        this.data = dataIn;
    }
    /**
     * @return Returns the time.
     */
    public Date getTime() {
        return time;
    }
    /**
     * @param timeIn The time to set.
     */
    public void setTime(Date timeIn) {
        this.time = timeIn;
    }

    /**
     * @return Returns the metric.
     */
    public String getMetric() {
        return metric;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
            return new ToStringBuilder(this).append("data", data).append("time",
                    time).append("metric", metric).toString();
        }


    /**
     * @return Returns the oid.
     */
    public String getOid() {
        return oid;
    }

}
