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
package com.redhat.rhn.domain.satellite;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.hibernate.Hibernate;

import java.sql.Blob;
import java.util.Date;

/**
 * SatelliteCertificate - Class representation of the table rhnSatelliteCert.
 * @version $Rev: 1 $
 */
public class SatelliteCertificate {

    private String label;
    private Long version;
    private byte[] cert;
    private Date issued;
    private Date expires;
    private Date created;
    private Date modified;
    /**
     * Getter for label
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /**
     * Setter for label
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * Getter for version
     * @return Long to get
    */
    public Long getVersion() {
        return this.version;
    }

    /**
     * Setter for version
     * @param versionIn to set
    */
    public void setVersion(Long versionIn) {
        this.version = versionIn;
    }

    /**
     * Getter for cert
     * @return Blob to get
    */
    public byte[] getCert() {
        return this.cert;
    }

    /**
     * Setter for cert
     * @param certIn to set
    */
    public void setCert(byte[] certIn) {
        this.cert = certIn;
    }

    /**
     * Let Hibernate get the cert blob, used only by Hibernate.
     * @return Returns the cert blob.
     */
    private Blob getCertBlob() {
        if (this.cert == null) {
            return null;
        }
        else {
            return Hibernate.createBlob(this.cert);
        }
    }

    /**
     * Let Hibernate set the cert Blob contents, used only by Hibernate.
     * @param certIn The cert to set.
     */
    private void setCertBlob(Blob certIn) {
        this.cert = HibernateFactory.blobToByteArray(certIn);
    }

    /**
     * Getter for issued
     * @return Date to get
    */
    public Date getIssued() {
        return this.issued;
    }

    /**
     * Setter for issued
     * @param issuedIn to set
    */
    public void setIssued(Date issuedIn) {
        this.issued = issuedIn;
    }

    /**
     * Getter for expires
     * @return Date to get
    */
    public Date getExpires() {
        return this.expires;
    }

    /**
     * Setter for expires
     * @param expiresIn to set
    */
    public void setExpires(Date expiresIn) {
        this.expires = expiresIn;
    }

    /**
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

}
