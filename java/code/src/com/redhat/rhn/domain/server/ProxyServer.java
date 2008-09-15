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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;

/**
 * Represents a ProxyServer
 * @version $Rev$
 */
public class ProxyServer extends Server {
    private PackageEvr version;

    /**
     * Constructs a ProxyServer
     */
    public ProxyServer() {
        super();
    }

    
    /**
     * @return Returns the version.
     */
    public PackageEvr getVersion() {
        return version;
    }

    
    /**
     * @param aVersion The version to set.
     */
    public void setVersion(PackageEvr aVersion) {
        version = aVersion;
    }
    
    /**
     * Sets the satellite version in epoch, version, release format.
     * @param e Epoch can be null.
     * @param v Version
     * @param r Release
     */
    public void setVersion(String e, String v, String r) {
        setVersion(PackageEvrFactory.createPackageEvr(e, v, r));
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean isProxy() {
        return true;
    }
}
