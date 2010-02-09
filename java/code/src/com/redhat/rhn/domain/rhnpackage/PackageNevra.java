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
package com.redhat.rhn.domain.rhnpackage;

/**
 * PackageName
 * @version $Rev$
 */
public class PackageNevra {

    private Long id;
    private PackageName name;
    private PackageEvr evr;
    private PackageArch arch;

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
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
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

}
