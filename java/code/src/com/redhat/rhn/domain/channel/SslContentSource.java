/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.kickstart.crypto.SslCryptoKey;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;


/**
 * SslContentSource
 * @version $Rev$
 */
public class SslContentSource extends BaseDomainHelper {

    private  SslCryptoKey caCert;
    private  SslCryptoKey clientCert;
    private  SslCryptoKey clientKey;

    /**
     * Constructor
     */
    public SslContentSource() {
    }

    /**
     * Copy Constructor
     * @param ssl ssl content source template
     */
    public SslContentSource(SslContentSource ssl) {
        caCert = ssl.getCaCert();
        clientCert = ssl.getClientCert();
        clientKey = ssl.getClientKey();
    }

    /**
     * @return Returns the caCert.
     */
    public SslCryptoKey getCaCert() {
        return caCert;
    }

    /**
     * @param caCertIn The caCert to set.
     */
    public void setCaCert(SslCryptoKey caCertIn) {
        caCert = caCertIn;
    }

    /**
     * @return Returns the clientCert.
     */
    public SslCryptoKey getClientCert() {
        return clientCert;
    }

    /**
     * @param clientCertIn The clientCert to set.
     */
    public void setClientCert(SslCryptoKey clientCertIn) {
        clientCert = clientCertIn;
    }

    /**
     * @return Returns the clientKey.
     */
    public SslCryptoKey getClientKey() {
        return clientKey;
    }

    /**
     * @param clientKeyIn The clientKey to set.
     */
    public void setClientKey(SslCryptoKey clientKeyIn) {
        clientKey = clientKeyIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof SslContentSource)) {
            return false;
        }

        SslContentSource r = (SslContentSource) obj;

        return new EqualsBuilder().append(r.getCaCert(), getCaCert())
                .append(r.getClientCert(), getClientCert())
                .append(r.getClientKey(), getClientKey())
                .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getCaCert())
                .append(getClientCert())
                .append(getClientKey())
                .toHashCode();
    }
}
