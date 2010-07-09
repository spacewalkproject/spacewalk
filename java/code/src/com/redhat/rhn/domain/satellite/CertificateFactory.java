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

import org.apache.log4j.Logger;

/**
 * SatelliteFactory
 * @version $Rev$
 */
public class CertificateFactory extends HibernateFactory {

    private static CertificateFactory singleton = new CertificateFactory();
    private static Logger log = Logger.getLogger(CertificateFactory.class);

    private CertificateFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * @return the newest versiono of the satellite's certificate
     */
    public static SatelliteCertificate lookupNewestCertificate() {
        return (SatelliteCertificate) singleton.lookupObjectByNamedQuery(
                "SatelliteCertificate.lookupNewestCertificate",
                null,
                false);
    }

}
