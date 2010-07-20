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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;

/**
 * SatelliteServer
 * @version $Rev$
 */
public class SatelliteServer extends Server {
    private byte[] cert;
    private String product;
    private String owner;
    // these are dates but are stored as strings. if we need to perform some
    // calculations on them we should probably make them Date classes.
    private String issued;  // dates
    private String expiration; // dates
    private PackageEvr version;

    /**
     * Constructs a SatelliteServer instance.
     */
    public SatelliteServer() {
        super();
    }

    /**
     * @return Returns the cert.
     */
    public String getCertString() {
        if (cert != null) {
            return new String(cert);
        }
        return null;
    }

    /**
     * Get the cert
     * @return the cert
     */
    public byte[] getCert() {
        return cert;
    }

    /**
     * @param aCert The cert to set.
     */
    public void setCert(String aCert) {
        cert = aCert.getBytes();
    }

    /**
     * @param aCert The cert to set.
     */
    public void setCert(byte[] aCert) {
        cert = aCert;
    }


    /**
     * @return Returns the expiration.
     */
    public String getExpiration() {
        return expiration;
    }

    /**
     * @param anExpiration The expiration to set.
     */
    public void setExpiration(String anExpiration) {
        expiration = anExpiration;
    }

    /**
     * @return Returns the issued.
     */
    public String getIssued() {
        return issued;
    }

    /**
     * @param issuedIn The issued to set.
     */
    public void setIssued(String issuedIn) {
        issued = issuedIn;
    }

    /**
     * @return Returns the owner.
     */
    public String getOwner() {
        return owner;
    }

    /**
     * @param anOwner The owner to set.
     */
    public void setOwner(String anOwner) {
        owner = anOwner;
    }

    /**
     * @return Returns the product.
     */
    public String getProduct() {
        return product;
    }

    /**
     * @param aProduct The product to set.
     */
    public void setProduct(String aProduct) {
        product = aProduct;
    }

    /**
     * @return Returns the version.
     */
    public PackageEvr getVersion() {
        return version;
    }

    /**
     * @param theVersion The version to set.
     */
    public void setVersion(PackageEvr theVersion) {
        version = theVersion;
    }

    /**
     * Sets the satellite version.
     * @param v Version
     */
    public void setVersion(String v) {
        setVersion(PackageEvrFactory.createPackageEvr(null, v, "1"));
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSatellite() {
        return true;
    }
}
