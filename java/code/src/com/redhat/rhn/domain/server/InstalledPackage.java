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

import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * 
 * InstalledPackage
 * This class is a representation of the rhnserverpackage table
 *    it does not map directly to the rhnpackage table, because it can 
 *    contain entries that do not correspond to an entry in the rhnpackage table.
 *    This is because it a system may have a package installed that the 
 *    satellite does not have. 
 *    This object is an instance of a package that is installed on a server
 * @version $Rev$
 */
public class InstalledPackage implements Serializable, Comparable<InstalledPackage> {

    /**
     * 
     */
    private static final long serialVersionUID = -6158622200264142583L;
    private PackageEvr evr;
    private PackageName name;
    private PackageArch arch;
    private Server server;
    private Date installTime;
    
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * @return Returns the arch.
     */
    public PackageArch getArch() {
        return arch;
    }
    
    /**
     * @param archIn The arch to set.
     */
    public void setArch(PackageArch archIn) {
        this.arch = archIn;
    }
    
    /**
     * @return Returns the evr.
     */
    public PackageEvr getEvr() {
        return evr;
    }
    
    /**
     * @param evrIn The evr to set.
     */
    public void setEvr(PackageEvr evrIn) {
        this.evr = evrIn;
    }
    
    /**
     * @return Returns the name.
     */
    public PackageName getName() {
        return name;
    }
    
    /**
     * @param nameIn The name to set.
     */
    public void setName(PackageName nameIn) {
        this.name = nameIn;
    }

    /**
     * Getter for installTime
     * @return Date when package was installed (as reported by rpm database).
    */
    public Date getInstallTime() {
        return this.installTime;
    }

    /**
     * Setter for installTime
     * @param installTimeIn to set
    */
    public void setInstallTime(Date installTimeIn) {
        this.installTime = installTimeIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        HashCodeBuilder builder =  new HashCodeBuilder().append(name.getName())
                                    .append(evr.getEpoch())
                                    .append(evr.getRelease())
                                    .append(evr.getVersion())
                                    .append(server.getId());
        if (this.arch != null) {
            builder.append(arch.getName());
        }
        return builder.toHashCode();
                                  
    }

    /** 
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        
        if (other instanceof InstalledPackage) {
            InstalledPackage otherPack = (InstalledPackage) other;
            return new EqualsBuilder().append(this.getName(), otherPack.getName())
                .append(this.getEvr(), otherPack.getEvr())
                .append(this.getServer(), otherPack.getServer())
                .append(this.getArch(), otherPack.getArch()).isEquals();
            
         
        }
        else if (other instanceof Package) {
            Package otherPack = (Package) other;

            EqualsBuilder builder =  new EqualsBuilder()
                .append(this.getName(), otherPack.getPackageName())
                .append(this.getEvr(), otherPack.getPackageEvr());
            
            if (this.getArch() != null) {
                builder.append(this.getArch(), otherPack.getPackageArch());
            }
            return builder.isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(InstalledPackage ip) {
        if (equals(ip)) {
            return 0;
        }
        if (!getName().equals(ip.getName())) {
            return getName().compareTo(ip.getName());
        }
        if (!getEvr().equals(ip.getEvr())) {
            return getEvr().compareTo(ip.getEvr());
        }
        if (getArch() != null) {
            return getArch().compareTo(ip.getArch());    
        }
        
        if (ip.getArch() != null) {
            return -1;
        }
        return 0;
    }
}
