/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.audit;

import java.util.Date;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.scap.ScapActionDetails;
import com.redhat.rhn.domain.server.Server;


/**
 * XccdfTestResult - Class representation of the table rhnXccdfTestResult.
 * @version $Rev$
 */
public class XccdfTestResult {

    private Long id;
    private Server server;
    private ScapActionDetails scapActionDetails;
    private XccdfBenchmark benchmark;
    private XccdfProfile profile;
    private String identifier;
    private Date startTime;
    private Date endTime;
    private byte[] errors;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for server
     * @return Server to get
     */
    public Server getServer() {
        return this.server;
    }

    /**
     * Setter for server
     * @param serverIn to set
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * Getter for scapActionDetails
     * @return ScapActionDetails to get
    */
    public ScapActionDetails getScapActionDetails() {
        return this.scapActionDetails;
    }

    /**
     * Setter for scapActionDetails
     * @param scapActionDetailsIn to set
    */
    public void setScapActionDetails(ScapActionDetails scapActionDetailsIn) {
        this.scapActionDetails = scapActionDetailsIn;
    }

    /**
     * Getter for benchmark
     * @return XccdfBenchmark to get
    */
    public XccdfBenchmark getBenchmark() {
        return this.benchmark;
    }

    /**
     * Setter for benchmark
     * @param benchmarkIn to set
    */
    public void setBenchmark(XccdfBenchmark benchmarkIn) {
        this.benchmark = benchmarkIn;
    }

    /**
     * Getter for profile
     * @return XccdfProfile to get
    */
    public XccdfProfile getProfile() {
        return this.profile;
    }

    /**
     * Setter for profile
     * @param profileIn to set
    */
    public void setProfile(XccdfProfile profileIn) {
        this.profile = profileIn;
    }

    /**
     * Getter for identifier
     * @return String to get
    */
    public String getIdentifier() {
        return this.identifier;
    }

    /**
     * Setter for identifier
     * @param identifierIn to set
    */
    public void setIdentifier(String identifierIn) {
        this.identifier = identifierIn;
    }

    /**
     * Getter for startTime
     * @return Date to get
    */
    public Date getStartTime() {
        return this.startTime;
    }

    /**
     * Setter for startTime
     * @param startTimeIn to set
    */
    public void setStartTime(Date startTimeIn) {
        this.startTime = startTimeIn;
    }

    /**
     * Getter for endTime
     * @return Date to get
    */
    public Date getEndTime() {
        return this.endTime;
    }

    /**
     * Setter for endTime
     * @param endTimeIn to set
    */
    public void setEndTime(Date endTimeIn) {
        this.endTime = endTimeIn;
    }

    /**
     * Getter for errors
     * @return errors
     */
    public byte[] getErrors() {
        return this.errors;
    }

    /**
     * Setter for errors
     * @param errorsIn to set
    */
    public void setErrors(byte[] errorsIn) {
        this.errors = errorsIn;
    }

    /**
     * Get the String version of the Errors contents
     * @return String version of the Errors contents
     */
    public String getErrrosContents() {
        return HibernateFactory.getByteArrayContents(this.errors);
    }
}
